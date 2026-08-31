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

By default, each module name corresponds to the RST filename in
programming-references/ (without extension). Some modules can define a custom
target path.
"""

import argparse
import difflib
import os
import re
import shutil
import sys

import pypandoc

# ── Source mapping: module-name → relative MD path inside sg-sdk ────────────
SOURCE_MAP = {
    "lora":           "src/comps/lora/docs/lora-main.md",
    "lora-wan":       "src/comps/lora/docs/lora-wan.md",
    "lora-raw":       "src/comps/lora/docs/lora-raw.md",
    "lora-callbacks": "src/comps/lora/docs/lora-callback.md",
    "lora-lctt":      "src/comps/lora/docs/lora-lctt.md",
    "ctrl-client":    "src/comps/ctrl-client/docs/user-api.md",
    "ftpd":           "src/platforms/F1/comps/ftp-server/ftpd.md",
    "telnetd":        "src/platforms/F1/comps/telnet-server/telnetd.md",
    "rgbled":         "src/platforms/F1/comps/rgbled-if/rgbled.md",
    "lte":            "src/platforms/F1/comps/lte/modlte.md",
    "lte-legacy":     "src/platforms/F1/comps/lte/lte_main.md",
    "can":            "src/platforms/F1/comps/can-if/can.md",
    "logs":           "src/libs/logs/docs/logs.md",
    "efuse":          "src/platforms/F1/comps/efuse-if/docs/efuse_if.md",
    "fuel-gauge":     "src/platforms/F1/comps/fuel-gauge-if/docs/fuel_gauge.md",
    "fuota":          "src/platforms/F1/comps/fuota/mod_fuota.md",
    "ioexp":          "src/platforms/F1/comps/ioexp-if/ioexp.md",
    "nvs":            "src/platforms/F1/comps/nvs-if/nvs_if.md",
    "sysinfo":        "src/platforms/F1/comps/sys-info/sysinfo.md",
    "sys-inspect":    "src/platforms/F1/comps/sys-inspect-if/docs/sys_inspect.md",
    "safeboot":       "src/platforms/F1/bootloader_components/boot-if/docs/safeboot.md",
    "firmware-development": "QuickStart.md",
    "arduino-ide":       "docs/ArduinoIDE.md",
    "arduino-packaging": "tools/arduino/README.md",
}

# Module targets that do not belong to programming-references/
TARGET_MAP = {
    "firmware-development": "firmware-development.rst",
    "arduino-ide":       "arduino/ide.rst",
    "arduino-packaging": "arduino/packaging.rst",
}

# Image/asset files to copy alongside a module (src rel to sg-sdk -> dest rel to
# sg-docs). pandoc leaves image paths untouched, so the destination must match
# the 'img/...' paths used inside the source Markdown.
ASSET_MAP = {
    "arduino-ide": [
        ("docs/img/board_url.png",       "arduino/img/board_url.png"),
        ("docs/img/package_install.png", "arduino/img/package_install.png"),
        ("docs/img/board_select.png",    "arduino/img/board_select.png"),
        ("docs/img/example_select.png",  "arduino/img/example_select.png"),
        ("docs/img/ctrl_token.png",      "arduino/img/ctrl_token.png"),
    ],
}

# Cross-document Markdown link targets -> Sphinx :doc: paths. The SDK Markdown
# links to sibling files by relative path; in the docs those become :doc:
# references to the generated pages instead.
LINK_MAP = {
    "docs/ArduinoIDE.md":         "/arduino/ide",
    "../QuickStart.md":           "/firmware-development",
    "../tools/arduino/README.md": "/arduino/packaging",
    "tools/arduino/README.md":    "/arduino/packaging",
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


def _protect_links(text):
    """Replace known cross-doc Markdown links with placeholders (pre-pandoc).

    Returns (text, mapping) where mapping is placeholder -> final :doc: role.
    Rewriting on the Markdown rather than the converted RST avoids pandoc's line
    wrapping splitting a link label across lines (which a regex would then miss
    or over-match).
    """
    links = {}
    counter = [0]
    for href, docpath in LINK_MAP.items():
        pattern = re.compile(r"\[([^\]\n]+)\]\(" + re.escape(href) + r"\)")

        def repl(m, docpath=docpath):
            label = m.group(1).strip().strip("`").strip()
            token = f"XDOCLINK{counter[0]}X"
            links[token] = ":doc:`" + label + " <" + docpath + ">`"
            counter[0] += 1
            return token

        text = pattern.sub(repl, text)
    return text, links


def _restore_links(text, links):
    """Swap link placeholders back for their :doc: roles (post-pandoc)."""
    for token, role in links.items():
        text = text.replace(token, role)
    return text


def md_to_rst(md_text):
    """Convert Markdown text to reStructuredText using pandoc."""
    md_text = _preprocess_md(md_text)
    md_text, links = _protect_links(md_text)
    rst = pypandoc.convert_text(
        md_text, "rst", format="gfm",
        extra_args=["--list-tables", "--wrap=auto", "--columns=79"],
    )
    rst = _postprocess_rst(rst)
    rst = _restore_links(rst, links)
    # Clean up excessive blank lines
    rst = re.sub(r"\n{3,}", "\n\n", rst)
    return rst.strip() + "\n"


# ── Main sync logic ────────────────────────────────────────────────────────

def _copy_assets(module, sdk_path, docs_path):
    """Copy a module's declared image/asset files into sg-docs."""
    for src_rel, dest_rel in ASSET_MAP.get(module, []):
        src = os.path.join(sdk_path, src_rel)
        dest = os.path.join(docs_path, dest_rel)
        if os.path.isfile(src):
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            shutil.copyfile(src, dest)

def sync_module(module, sdk_path, docs_path, dry_run=False, show_diff=False):
    """Sync a single module from sg-sdk MD to sg-docs RST.

    Returns: (changed: bool, summary: str)
    """
    if module not in SOURCE_MAP:
        return False, f"  SKIP {module}: not in SOURCE_MAP"

    md_rel = SOURCE_MAP[module]
    md_path = os.path.join(sdk_path, md_rel)
    target_rel = TARGET_MAP.get(module, os.path.join("programming-references", f"{module}.rst"))
    rst_path = os.path.join(docs_path, target_rel)

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
        return False, f"  OK   {module}: up to date ({target_rel})"

    if show_diff:
        diff = difflib.unified_diff(
            old_rst.splitlines(keepends=True),
            new_rst.splitlines(keepends=True),
            fromfile=f"{target_rel} (current)",
            tofile=f"{target_rel} (from sdk)",
            lineterm="",
        )
        diff_text = "\n".join(diff)
        if diff_text:
            print(diff_text)
            print()

    if not dry_run:
        os.makedirs(os.path.dirname(rst_path), exist_ok=True)
        with open(rst_path, "w") as f:
            f.write(new_rst)
        _copy_assets(module, sdk_path, docs_path)
        return True, f"  SYNC {module}: updated {target_rel}"
    else:
        return True, f"  WOULD {module}: {target_rel} needs update"


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
            target_rel = TARGET_MAP.get(mod, os.path.join("programming-references", f"{mod}.rst"))
            print(f"  {exists} {mod:20s} ← {md_rel}  ->  {target_rel}")
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
