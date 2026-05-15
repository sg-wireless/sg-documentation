#!/usr/bin/env bash
# build_versions.sh — Build multiple doc versions from git tags.
#
# Usage:  ./build_versions.sh [TAG ...]
#   No arguments → builds every v*.*.* tag found in the repo.
#   With arguments → builds only the listed tags, e.g. ./build_versions.sh v1.3.0 v1.4.0
#
# Output lands in _build/html/<tag>/  with a root index.html that
# redirects to the latest (highest semver) version.

set -euo pipefail

SRCDIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="$SRCDIR/_build/html"
PDF_BUILD_TIMEOUT_SEC="${PDF_BUILD_TIMEOUT_SEC:-1200}"

build_pdf_noninteractive() {
  local source_dir="$1"
  local build_dir="$2"
  local version_label="$3"
  local latex_dir="$build_dir/latex"
  local tex_file
  local tex_name
  local tex_base

  echo "--- Building PDF for $version_label (timeout ${PDF_BUILD_TIMEOUT_SEC}s) ---"

  # Step 1: Generate LaTeX sources.
  timeout "$PDF_BUILD_TIMEOUT_SEC" sphinx-build -b latex -j auto "$source_dir" "$latex_dir"

  # Step 2: Normalize known image incompatibilities in the generated latex tree.
  normalize_latex_assets "$latex_dir"

  tex_file="$(find "$latex_dir" -maxdepth 1 -type f -name '*.tex' | head -1)"
  if [[ -z "$tex_file" ]]; then
    echo "ERROR: No .tex file generated under $latex_dir"
    return 1
  fi

  tex_name="$(basename "$tex_file")"
  tex_base="${tex_name%.tex}"

  # Step 3: Compile PDF non-interactively.
  if command -v latexmk >/dev/null 2>&1; then
    timeout "$PDF_BUILD_TIMEOUT_SEC" env \
      LATEXMKOPTS="-interaction=nonstopmode -halt-on-error -file-line-error -f" \
      latexmk -cd -pdfxe -interaction=nonstopmode -halt-on-error -file-line-error -f "$tex_file"
  elif command -v xelatex >/dev/null 2>&1; then
    echo "WARNING: latexmk not found; falling back to direct xelatex build"
    timeout "$PDF_BUILD_TIMEOUT_SEC" bash -c '
      set -euo pipefail
      cd "$1"
      xelatex -interaction=nonstopmode -halt-on-error -file-line-error "$2"
      if [[ -f "$3.idx" ]] && command -v makeindex >/dev/null 2>&1; then
        makeindex "$3.idx"
      fi
      xelatex -interaction=nonstopmode -halt-on-error -file-line-error "$2"
      xelatex -interaction=nonstopmode -halt-on-error -file-line-error "$2"
    ' _ "$latex_dir" "$tex_name" "$tex_base"
  elif command -v tectonic >/dev/null 2>&1; then
    echo "WARNING: latexmk/xelatex not found; falling back to tectonic build"
    timeout "$PDF_BUILD_TIMEOUT_SEC" bash -c '
      set -euo pipefail
      cd "$1"
      tectonic --keep-logs --outdir "$1" "$2"
      if [[ -f "$3.idx" ]] && command -v makeindex >/dev/null 2>&1; then
        makeindex "$3.idx"
        tectonic --keep-logs --outdir "$1" "$2"
      fi
      tectonic --keep-logs --outdir "$1" "$2"
    ' _ "$latex_dir" "$tex_name" "$tex_base"
  else
    echo "ERROR: None of latexmk, xelatex, or tectonic is available in PATH"
    return 127
  fi
}

normalize_latex_assets() {
  local latex_dir="$1"
  python3 - "$latex_dir" <<'PY'
import sys
from pathlib import Path

try:
  from PIL import Image
except ModuleNotFoundError:
  print("ERROR: Pillow is required for PDF asset normalization. Install it with: pip install Pillow", file=sys.stderr)
  raise SystemExit(2)

latex_dir = Path(sys.argv[1])
converted_webp = 0
converted_gif = 0
updated_tex_files = 0
updated_font_refs = 0

# Fix mislabeled WEBP files saved with .png/.jpg/.jpeg extensions.
for pattern in ("*.png", "*.jpg", "*.jpeg"):
  for path in latex_dir.rglob(pattern):
    try:
      with Image.open(path) as img:
        fmt = (img.format or "").upper()
        if fmt != "WEBP":
          continue

        ext = path.suffix.lower()
        if ext == ".png":
          save_format = "PNG"
        else:
          save_format = "JPEG"
          if img.mode not in ("RGB", "L"):
            img = img.convert("RGB")

        img.save(path, save_format)
        converted_webp += 1
    except Exception:
      continue

# Convert GIFs to PNG (first frame) and rewrite latex references accordingly.
for gif_path in latex_dir.rglob("*.gif"):
  png_path = gif_path.with_suffix(".png")
  try:
    with Image.open(gif_path) as img:
      if img.mode not in ("RGB", "RGBA", "L"):
        img = img.convert("RGBA")
      img.save(png_path, "PNG")
      converted_gif += 1
  except Exception:
    continue

for tex_path in latex_dir.glob("*.tex"):
  original = tex_path.read_text(encoding="utf-8", errors="ignore")
  updated = original.replace(".gif}", ".png}")

  # Sphinx XeLaTeX defaults may reference Free* fonts that are not present
  # in minimal CI environments; remap to DejaVu families that we install in CI.
  updated = updated.replace("FreeSerif", "DejaVu Serif")
  updated = updated.replace("FreeSans", "DejaVu Sans")
  updated = updated.replace("FreeMono", "DejaVu Sans Mono")

  if updated != original:
    if (
      "FreeSerif" in original
      or "FreeSans" in original
      or "FreeMono" in original
    ):
      updated_font_refs += 1
    tex_path.write_text(updated, encoding="utf-8")
    updated_tex_files += 1

print(f"Converted mislabeled WEBP images: {converted_webp}")
print(f"Converted GIF images to PNG: {converted_gif}")
print(f"Updated LaTeX files (asset refs/fonts): {updated_tex_files}")
print(f"Updated LaTeX files with font remaps: {updated_font_refs}")
PY
}

# -------------------------------------------------------------------
# Branch detection: on non-main branches, build only the current
# working tree as a preview (no tag checkout, no multi-version).
# This lets Amplify preview deployments show uncommitted / untagged
# changes from feature branches.
# -------------------------------------------------------------------
CURRENT_BRANCH="${AWS_BRANCH:-$(git -C "$SRCDIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)}"

if [[ "$CURRENT_BRANCH" != "main" ]]; then
    PREVIEW_TAG="preview"
    echo "=== Preview build for branch '$CURRENT_BRANCH' (single version) ==="

    rm -rf "$OUTDIR"
    mkdir -p "$OUTDIR"

    ALL_JSON="[\"$PREVIEW_TAG\"]"

    SGW_CURRENT_VERSION="$PREVIEW_TAG" \
    SGW_ALL_VERSIONS="$ALL_JSON" \
    sphinx-build -b html -j auto "$SRCDIR" "$OUTDIR/$PREVIEW_TAG"

    # Build preview PDF from the current working tree and publish it under
    # the same version-scoped path used by the flyout download link.
    SGW_CURRENT_VERSION="$PREVIEW_TAG" \
    SGW_ALL_VERSIONS="$ALL_JSON" \
    build_pdf_noninteractive "$SRCDIR" "$SRCDIR/_build" "$PREVIEW_TAG"
    mkdir -p "$OUTDIR/$PREVIEW_TAG/_static"
    cp "$SRCDIR/_build/latex/SGWirelessDocs.pdf" "$OUTDIR/$PREVIEW_TAG/_static/SGWirelessDocs.pdf"

    # Root redirect → preview
    cat > "$OUTDIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url=./${PREVIEW_TAG}/index.html">
  <title>Redirecting…</title>
</head>
<body>
  <p>Redirecting to <a href="./${PREVIEW_TAG}/index.html">${PREVIEW_TAG}</a>…</p>
</body>
</html>
EOF

    echo ""
    echo "=== Done — preview build in $OUTDIR/$PREVIEW_TAG ==="
    exit 0
fi

# -------------------------------------------------------------------
# Ensure tags are available (CI environments often use shallow clones)
# -------------------------------------------------------------------
git -C "$SRCDIR" fetch --tags 2>/dev/null || true

# -------------------------------------------------------------------
# Collect version tags (sorted descending so index 0 = latest)
# -------------------------------------------------------------------
if [[ $# -gt 0 ]]; then
    TAGS=("$@")
else
    mapfile -t TAGS < <(git -C "$SRCDIR" tag -l 'v[0-9]*' --sort=-version:refname)
fi

if [[ ${#TAGS[@]} -eq 0 ]]; then
    echo "ERROR: No version tags found. Create at least one tag like v1.4.0."
    exit 1
fi

LATEST="${TAGS[0]}"
ALL_JSON=$(printf '%s\n' "${TAGS[@]}" | python3 -c \
    'import sys,json; print(json.dumps([l.strip() for l in sys.stdin]))')

echo "=== Building versions: ${TAGS[*]}  (latest=$LATEST) ==="

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

# -------------------------------------------------------------------
# Build each version
# -------------------------------------------------------------------
for TAG in "${TAGS[@]}"; do
    echo ""
    echo "--- Building $TAG ---"
    WORKDIR=$(mktemp -d)
    # Export the full tree at that tag into a temp directory
    git -C "$SRCDIR" archive "$TAG" | tar -x -C "$WORKDIR"

    # Copy templates, static, and config from the current branch so the
    # version flyout logic stays consistent across versions.
    # Keep each tag's own index.rst to avoid cross-version content breakage.
    cp -r "$SRCDIR/_templates" "$WORKDIR/_templates"
    cp -r "$SRCDIR/_static" "$WORKDIR/_static"
    cp "$SRCDIR/conf.py" "$WORKDIR/conf.py"

    SGW_CURRENT_VERSION="$TAG" \
    SGW_ALL_VERSIONS="$ALL_JSON" \
    sphinx-build -b html -j auto "$WORKDIR" "$OUTDIR/$TAG"

    # Build a PDF from the same tagged tree so each version has a matching
    # downloadable PDF in /<tag>/_static/SGWirelessDocs.pdf.
    SGW_CURRENT_VERSION="$TAG" \
    SGW_ALL_VERSIONS="$ALL_JSON" \
    build_pdf_noninteractive "$WORKDIR" "$WORKDIR/_build" "$TAG"
    mkdir -p "$OUTDIR/$TAG/_static"
    cp "$WORKDIR/_build/latex/SGWirelessDocs.pdf" "$OUTDIR/$TAG/_static/SGWirelessDocs.pdf"

    rm -rf "$WORKDIR"
done

# -------------------------------------------------------------------
# Root redirect → latest version
# -------------------------------------------------------------------
cat > "$OUTDIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url=./${LATEST}/index.html">
  <title>Redirecting…</title>
</head>
<body>
  <p>Redirecting to <a href="./${LATEST}/index.html">${LATEST}</a>…</p>
</body>
</html>
EOF

echo ""
echo "=== Done — output in $OUTDIR ==="
echo "    Latest: $LATEST"
echo "    Versions: ${TAGS[*]}"
