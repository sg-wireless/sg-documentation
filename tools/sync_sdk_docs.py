#!/usr/bin/env python3
"""
sync_sdk_docs.py — Synchronise sg-sdk Markdown API docs → sg-docs RST files.

Usage:
    python3 tools/sync_sdk_docs.py [options] [MODULE ...]

    # sync all modules
    python3 tools/sync_sdk_docs.py

    # sync specific module(s)
    python3 tools/sync_sdk_docs.py lora-wan lora-raw

    # dry-run (show what would change without writing)
    python3 tools/sync_sdk_docs.py --dry-run

    # show diff of what would change
    python3 tools/sync_sdk_docs.py --diff

    # specify custom sg-sdk path
    python3 tools/sync_sdk_docs.py --sdk-path /path/to/sg-sdk

Each module name corresponds to the RST filename in api/ (without extension).
"""

import argparse
import difflib
import os
import re
import sys

import pypandoc

# ── Source mapping: module-name → relative MD path inside sg-sdk ────────────
SOURCE_MAP = {
    "lora":           "src/comps/lora/docs/lora-main.md",
    "lora-wan":       "src/comps/lora/docs/lora-wan.md",
    "lora-raw":       "src/comps/lora/docs/lora-raw.md",
    "lora-callbacks": "src/comps/lora/docs/lora-callback.md",
    "ctrl-client":    "src/comps/ctrl-client/docs/user-api.md",
    "rgbled":         "src/platforms/F1/comps/rgbled-if/rgbled.md",
    "lte":            "src/platforms/F1/comps/lte/modlte.md",
    "lte-legacy":     "src/platforms/F1/comps/lte/lte_main.md",
    "can":            "src/platforms/F1/comps/can-if/can.md",
    "efuse":          "src/platforms/F1/comps/efuse-if/docs/efuse_if.md",
    "fuel-gauge":     "src/platforms/F1/comps/fuel-gauge-if/docs/fuel_gauge.md",
    "fuota":          "src/platforms/F1/comps/fuota/mod_fuota.md",
    "ioexp":          "src/platforms/F1/comps/ioexp-if/ioexp.md",
    "nvs":            "src/platforms/F1/comps/nvs-if/nvs_if.md",
    "sysinfo":        "src/platforms/F1/comps/sys-info/sysinfo.md",
    "sys-inspect":    "src/platforms/F1/comps/sys-inspect-if/docs/sys_inspect.md",
    "safeboot":       "src/platforms/F1/bootloader_components/boot-if/docs/safeboot.md",
}

# ── Markdown → RST converter (pandoc-based) ────────────────────────────────


def _preprocess_md(text):
    """Clean up sg-sdk Markdown before handing it to pandoc."""
    # Remove HTML comments (copyright headers, section separators)
    text = re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL)
    # Remove <div id="..."></div> anchor targets
    text = re.sub(r"<div[^>]*>\s*</div>", "", text)
    # Simplify anchor-only links: [`text`](#anchor) → `text`
    text = re.sub(r"\[`([^]]+?)`\]\(#[^)]*\)", r"`\1`", text)
    # Simplify anchor-only links without backticks: [text](#anchor) → text
    text = re.sub(r"\[([^]]+?)\]\(#[^)]*\)", r"\1", text)
    return text


def _postprocess_rst(text):
    """Post-process pandoc RST output for Sphinx compatibility."""
    lines = text.split("\n")
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        # Convert italic *REMARK* paragraphs to .. note:: directives
        m = re.match(r"^\*REMARK\*\s*(.*)", line)
        if m:
            note_body = m.group(1)
            # Collect continuation lines
            i += 1
            while i < len(lines) and lines[i].strip() and not lines[i].startswith(".."):
                note_body += " " + lines[i].strip()
                i += 1
            out.append("")
            out.append(".. note::")
            out.append("")
            out.append(f"   {note_body}")
            out.append("")
            continue
        out.append(line)
        i += 1
    return "\n".join(out)


def md_to_rst(md_text):
    """Convert Markdown text to reStructuredText using pandoc."""
    md_text = _preprocess_md(md_text)
    rst = pypandoc.convert_text(
        md_text, "rst", format="gfm",
        extra_args=["--list-tables", "--wrap=auto", "--columns=79"],
    )
    rst = _postprocess_rst(rst)
    # Clean up excessive blank lines
    rst = re.sub(r"\n{3,}", "\n\n", rst)
    return rst.strip() + "\n"


# ── Main sync logic ────────────────────────────────────────────────────────


def sync_module(module, sdk_path, docs_path, dry_run=False, show_diff=False):
    """Sync a single module from sg-sdk MD to sg-docs RST.

    Returns: (changed: bool, summary: str)
    """
    if module not in SOURCE_MAP:
        return False, f"  SKIP {module}: not in SOURCE_MAP"

    md_rel = SOURCE_MAP[module]
    md_path = os.path.join(sdk_path, md_rel)
    rst_path = os.path.join(docs_path, "api", f"{module}.rst")

    if not os.path.isfile(md_path):
        return False, f"  SKIP {module}: source not found: {md_rel}"

    with open(md_path, "r") as f:
        md_text = f.read()

    new_rst = md_to_rst(md_text)

    # Read existing RST if present
    old_rst = ""
    if os.path.isfile(rst_path):
        with open(rst_path, "r") as f:
            old_rst = f.read()

    if old_rst == new_rst:
        return False, f"  OK   {module}: up to date"

    if show_diff:
        diff = difflib.unified_diff(
            old_rst.splitlines(keepends=True),
            new_rst.splitlines(keepends=True),
            fromfile=f"api/{module}.rst (current)",
            tofile=f"api/{module}.rst (from sdk)",
            lineterm="",
        )
        diff_text = "\n".join(diff)
        if diff_text:
            print(diff_text)
            print()

    if not dry_run:
        with open(rst_path, "w") as f:
            f.write(new_rst)
        return True, f"  SYNC {module}: updated api/{module}.rst"
    else:
        return True, f"  WOULD {module}: api/{module}.rst needs update"


def main():
    parser = argparse.ArgumentParser(
        description="Sync sg-sdk Markdown API docs to sg-docs RST files."
    )
    parser.add_argument(
        "modules",
        nargs="*",
        help="Module names to sync (default: all). E.g. lora-wan lora-raw",
    )
    parser.add_argument(
        "--sdk-path",
        default=None,
        help="Path to sg-sdk repo (default: auto-detect from ../sg-sdk)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be updated without writing files.",
    )
    parser.add_argument(
        "--diff",
        action="store_true",
        help="Show unified diff of changes.",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List all known module mappings and exit.",
    )

    args = parser.parse_args()

    # Resolve paths
    docs_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    if args.sdk_path:
        sdk_path = os.path.abspath(args.sdk_path)
    else:
        # Auto-detect: assume sg-sdk is sibling to sg-docs
        sdk_path = os.path.join(os.path.dirname(docs_path), "sg-sdk")

    if args.list:
        print("Known module mappings (sg-sdk MD → sg-docs RST):\n")
        for mod, md_rel in sorted(SOURCE_MAP.items()):
            md_full = os.path.join(sdk_path, md_rel)
            exists = "✓" if os.path.isfile(md_full) else "✗"
            print(f"  {exists} {mod:20s} ← {md_rel}")
        return

    if not os.path.isdir(sdk_path):
        print(f"ERROR: sg-sdk not found at {sdk_path}", file=sys.stderr)
        print("  Use --sdk-path to specify the location.", file=sys.stderr)
        sys.exit(1)

    modules = args.modules if args.modules else sorted(SOURCE_MAP.keys())

    print(f"sg-sdk:  {sdk_path}")
    print(f"sg-docs: {docs_path}")
    print(f"modules: {', '.join(modules)}")
    if args.dry_run:
        print("mode:    DRY RUN")
    print()

    changed = 0
    for mod in modules:
        was_changed, msg = sync_module(
            mod, sdk_path, docs_path,
            dry_run=args.dry_run,
            show_diff=args.diff,
        )
        print(msg)
        if was_changed:
            changed += 1

    print()
    if args.dry_run:
        print(f"Would update {changed} file(s).")
    else:
        print(f"Updated {changed} file(s).")


if __name__ == "__main__":
    main()
