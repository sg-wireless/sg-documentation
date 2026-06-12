#!/usr/bin/env bash
# build_versions.sh — Build multiple doc versions from git tags.
#
# Usage:  ./build_versions.sh [TAG ...]
#   No arguments → builds every v*.*.* tag found in the repo.
#   With arguments → builds only the listed tags, e.g. ./build_versions.sh v1.3.0 v1.4.0
#
# Output lands in _build/html/<tag>/  with a root index.html that
# redirects to the latest (highest semver) version.
#
# On the main branch the latest version is always built from the current
# working tree (HEAD) rather than the tagged commit.  This means that a
# merged PR triggers a correct build immediately without having to move
# the tag first.  The tag still determines the version label (e.g. v1.4.0)
# shown in the flyout.
#
# On any other branch a single-version "preview" build of the current
# working tree is produced instead.  Updating the tag before pushing is
# fine for those branches since they don't use the working-tree shortcut.
#
# Build Caching (GitHub Releases):
#   Non-latest version builds are cached as GitHub releases for both
#   offline download and build speed optimization. Releases are named
#   v1.3.0-<commit-hash> and include:
#     - v1.3.0-docs.tar.gz (HTML archive for offline viewing)
#     - v1.3.0-SGWirelessDocs.pdf (PDF documentation)
#
#   Required for caching:
#     - GITHUB_REPOSITORY (format: owner/repo, auto-detected from git remote)
#     - GITHUB_TOKEN (for gh CLI authentication)
#     - gh CLI installed
#
#   To disable caching: export SKIP_BUILD_CACHE=true
#
#   Cache invalidation: If docs content for a tag changes, re-tag at the
#   new commit → new release name → fresh build. Latest version is never cached.
#
#   Manual download: Users can download releases from GitHub for offline viewing.
#   Extract the archive and open <tag>/index.html in a web browser.

set -euo pipefail

SRCDIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="$SRCDIR/_build/html"
PDF_BUILD_TIMEOUT_SEC="${PDF_BUILD_TIMEOUT_SEC:-1200}"

# Auto-detect GitHub repository from git remote (if not already set)
if [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
    GITHUB_REPOSITORY=$(git -C "$SRCDIR" remote get-url origin 2>/dev/null | \
        sed -n 's|^.*github\.com[:/]\(.*\)\.git$|\1|p' || echo "")
    if [[ -n "$GITHUB_REPOSITORY" ]]; then
        echo "Auto-detected GITHUB_REPOSITORY: $GITHUB_REPOSITORY"
    fi
fi

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
  if command -v latexmk >/dev/null 2>&1 && command -v xelatex >/dev/null 2>&1; then
    timeout "$PDF_BUILD_TIMEOUT_SEC" env \
      LATEXMKOPTS="-interaction=nonstopmode -halt-on-error -file-line-error -f" \
      latexmk -cd -pdfxe -interaction=nonstopmode -halt-on-error -file-line-error -f "$tex_file"
  elif command -v latexmk >/dev/null 2>&1 && command -v lualatex >/dev/null 2>&1; then
    echo "WARNING: xelatex not found; falling back to latexmk+lualatex"
    timeout "$PDF_BUILD_TIMEOUT_SEC" env \
      LATEXMKOPTS="-interaction=nonstopmode -halt-on-error -file-line-error -f" \
      latexmk -cd -pdflua -interaction=nonstopmode -halt-on-error -file-line-error -f "$tex_file"
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
  elif command -v lualatex >/dev/null 2>&1; then
    echo "WARNING: latexmk/xelatex not found; falling back to direct lualatex build"
    timeout "$PDF_BUILD_TIMEOUT_SEC" bash -c '
      set -euo pipefail
      cd "$1"
      lualatex -interaction=nonstopmode -halt-on-error -file-line-error "$2"
      if [[ -f "$3.idx" ]] && command -v makeindex >/dev/null 2>&1; then
        makeindex "$3.idx"
      fi
      lualatex -interaction=nonstopmode -halt-on-error -file-line-error "$2"
      lualatex -interaction=nonstopmode -halt-on-error -file-line-error "$2"
    ' _ "$latex_dir" "$tex_name" "$tex_base"
  elif command -v tectonic >/dev/null 2>&1; then
    echo "WARNING: latexmk/xelatex/lualatex not found; falling back to tectonic build"
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
    echo "ERROR: No usable PDF engine found. Need one of: xelatex, lualatex, or tectonic (latexmk optional)."
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

  if updated != original:
    tex_path.write_text(updated, encoding="utf-8")
    updated_tex_files += 1

print(f"Converted mislabeled WEBP images: {converted_webp}")
print(f"Converted GIF images to PNG: {converted_gif}")
print(f"Updated LaTeX files (asset refs/fonts): {updated_tex_files}")
PY
}

# -------------------------------------------------------------------
# Build cache management — uses GitHub releases to store/retrieve
# pre-built artifacts for immutable version tags.
# Releases are named v1.3.0-<commit> for easy discovery and download.
# -------------------------------------------------------------------
fetch_cached_build() {
    local tag="$1"
    local commit_hash="$2"
    local release_tag="$tag-${commit_hash:0:7}"
    local archive_name="$tag-docs.tar.gz"

    echo "  Checking for cached build: $release_tag"

    # Require gh CLI and GITHUB_REPOSITORY for cache operations
    if ! command -v gh >/dev/null 2>&1; then
        echo "  gh CLI not found — skipping cache"
        return 1
    fi
    if [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
        echo "  GITHUB_REPOSITORY not set — skipping cache"
        return 1
    fi

    # Check if release exists
    if ! gh release view "$release_tag" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
        echo "  No cache found"
        return 1
    fi

    echo "  Cache found! Downloading..."

    # Download archive
    local temp_file
    temp_file=$(mktemp)
    if ! gh release download "$release_tag" --repo "$GITHUB_REPOSITORY" --pattern "$archive_name" --output "$temp_file" 2>/dev/null; then
        echo "  Failed to download cache asset"
        rm -f "$temp_file"
        return 1
    fi

    # Extract to output directory
    mkdir -p "$OUTDIR"
    if ! tar -xzf "$temp_file" -C "$OUTDIR"; then
        echo "  Failed to extract cache"
        rm -f "$temp_file"
        rm -rf "$OUTDIR/$tag"
        return 1
    fi

    rm -f "$temp_file"
    echo "  ✓ Restored $tag from release $release_tag"
    return 0
}

store_cached_build() {
    local tag="$1"
    local commit_hash="$2"
    local release_tag="$tag-${commit_hash:0:7}"
    local archive_name="$tag-docs.tar.gz"
    local pdf_name="$tag-SGWirelessDocs.pdf"

    echo "  Creating release for offline download and future build cache..."

    # Require gh CLI and GITHUB_REPOSITORY
    if ! command -v gh >/dev/null 2>&1 || [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
        echo "  Skipping release (gh CLI or GITHUB_REPOSITORY unavailable)"
        return 1
    fi

    # Create tarball of this version's output directory
    local temp_archive
    temp_archive=$(mktemp)
    if ! tar -czf "$temp_archive" -C "$OUTDIR" "$tag"; then
        echo "  Failed to create docs archive"
        rm -f "$temp_archive"
        return 1
    fi

    # Copy PDF to temp location for upload
    local temp_pdf
    temp_pdf=$(mktemp)
    if [[ -f "$OUTDIR/$tag/_static/SGWirelessDocs.pdf" ]]; then
        cp "$OUTDIR/$tag/_static/SGWirelessDocs.pdf" "$temp_pdf"
    else
        echo "  WARNING: PDF not found at $OUTDIR/$tag/_static/SGWirelessDocs.pdf"
        rm -f "$temp_archive"
        return 1
    fi

    # Create GitHub release with both archive and PDF
    if ! gh release create "$release_tag" \
        --repo "$GITHUB_REPOSITORY" \
        --title "Documentation $tag" \
        --notes "**SG Wireless Documentation $tag**

This release contains the complete documentation for version $tag in two formats:

📦 **$archive_name** — HTML documentation archive
   Extract and open \`$tag/index.html\` in a web browser for offline viewing.

📄 **$pdf_name** — PDF documentation
   Complete documentation in PDF format.

---
*This release is auto-generated by the build system and serves as both a download source and build cache. Commit: $commit_hash*" \
        --target "$commit_hash" \
        "$temp_archive#$archive_name" \
        "$temp_pdf#$pdf_name" 2>/dev/null; then
        echo "  Failed to create release (may already exist or lack permissions)"
        rm -f "$temp_archive" "$temp_pdf"
        return 1
    fi

    rm -f "$temp_archive" "$temp_pdf"
    echo "  ✓ Release created: $release_tag"
    return 0
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

    # Root redirect → preview (absolute URL so it can't accumulate when
    # Amplify rewrites a 404 to this page while keeping the requested URL).
    cat > "$OUTDIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url=/${PREVIEW_TAG}/index.html">
  <title>Redirecting…</title>
</head>
<body>
  <p>Redirecting to <a href="/${PREVIEW_TAG}/index.html">${PREVIEW_TAG}</a>…</p>
</body>
</html>
EOF

    # Stable, version-independent downloads (same as the production build)
    # so preview deployments can validate the permanent /downloads/<name> path.
    if [[ -d "$SRCDIR/_static/downloads" ]]; then
        mkdir -p "$OUTDIR/downloads"
        cp -r "$SRCDIR/_static/downloads/." "$OUTDIR/downloads/"
        echo "Published stable downloads to $OUTDIR/downloads"
    fi

    echo ""
    echo "=== Done — preview build in $OUTDIR/$PREVIEW_TAG ==="
    exit 0
fi

# -------------------------------------------------------------------
# Ensure tags are available (CI environments often use shallow clones)
# -------------------------------------------------------------------
git -C "$SRCDIR" fetch --tags 2>/dev/null || true

# -------------------------------------------------------------------
# Collect version tags (sorted descending so highest semver comes first)
# -------------------------------------------------------------------
if [[ $# -gt 0 ]]; then
    mapfile -t ALL_TAGS < <(printf '%s\n' "$@" | sort -rV)
else
    mapfile -t ALL_TAGS < <(git -C "$SRCDIR" tag -l 'v[0-9]*' --sort=-version:refname)
fi

# Separate into clean release tags (vX.Y.Z) and pre-release tags (vX.Y.Z-suffix).
# Only release tags are eligible for "latest"; pre-release tags appear in the
# flyout with their suffix shown as a label, e.g. v1.4.1 (dev).
RELEASE_TAGS=()
PRERELEASE_TAGS=()
for _t in "${ALL_TAGS[@]}"; do
    if [[ "$_t" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        RELEASE_TAGS+=("$_t")
    else
        PRERELEASE_TAGS+=("$_t")
    fi
done

if [[ ${#RELEASE_TAGS[@]} -eq 0 ]]; then
    echo "ERROR: No release version tags found. Create at least one vX.Y.Z tag (no suffix)."
    exit 1
fi

# Build order: release versions first (desc), then pre-release (desc).
LATEST="${RELEASE_TAGS[0]}"
TAGS=("${RELEASE_TAGS[@]}" "${PRERELEASE_TAGS[@]}")
ALL_JSON=$(python3 -c 'import sys,json; print(json.dumps(sys.argv[1:]))' "${TAGS[@]}")

echo "=== Building versions: ${TAGS[*]}  (latest=$LATEST) ==="
[[ ${#PRERELEASE_TAGS[@]} -gt 0 ]] && echo "    Pre-release: ${PRERELEASE_TAGS[*]}"
echo "    '$LATEST' will be built from main HEAD (not the tag) so merged PRs are live immediately."

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

# -------------------------------------------------------------------
# Build each version
# -------------------------------------------------------------------
CACHED_COUNT=0
BUILT_COUNT=0

for TAG in "${TAGS[@]}"; do
    echo ""
    echo "--- Building $TAG ---"

    # Latest version is always built from HEAD (never cached)
    if [[ "$TAG" == "$LATEST" ]]; then
        echo "  Latest version — building from HEAD (no cache)"
        WORKDIR="$SRCDIR"
        SHOULD_CACHE=false
        BUILT_COUNT=$((BUILT_COUNT + 1))
    else
        # Get commit hash for this version tag
        COMMIT_HASH=$(git -C "$SRCDIR" rev-list -n 1 "$TAG")

        # Try to restore from cache (unless explicitly disabled)
        if [[ "${SKIP_BUILD_CACHE:-}" == "true" ]]; then
            echo "  Build cache disabled (SKIP_BUILD_CACHE=true)"
        elif fetch_cached_build "$TAG" "$COMMIT_HASH"; then
            echo "  Skipping build — using cached artifacts"
            CACHED_COUNT=$((CACHED_COUNT + 1))
            continue  # Move to next version
        fi

        # Cache miss or disabled — proceed with normal build
        WORKDIR=$(mktemp -d)
        git -C "$SRCDIR" archive "$TAG" | tar -x -C "$WORKDIR"

        # Copy templates, static, and config from the current branch so the
        # version flyout logic stays consistent across versions.
        cp -r "$SRCDIR/_templates" "$WORKDIR/_templates"
        cp -r "$SRCDIR/_static" "$WORKDIR/_static"
        cp "$SRCDIR/conf.py" "$WORKDIR/conf.py"
        SHOULD_CACHE=true
        BUILT_COUNT=$((BUILT_COUNT + 1))
    fi

    SGW_CURRENT_VERSION="$TAG" \
    SGW_ALL_VERSIONS="$ALL_JSON" \
    SGW_LATEST_VERSION="$LATEST" \
    sphinx-build -b html -j auto "$WORKDIR" "$OUTDIR/$TAG"

    # Build a PDF from the same tree so each version has a matching
    # downloadable PDF in /<tag>/_static/SGWirelessDocs.pdf.
    SGW_CURRENT_VERSION="$TAG" \
    SGW_ALL_VERSIONS="$ALL_JSON" \
    SGW_LATEST_VERSION="$LATEST" \
    build_pdf_noninteractive "$WORKDIR" "$WORKDIR/_build" "$TAG"
    mkdir -p "$OUTDIR/$TAG/_static"
    cp "$WORKDIR/_build/latex/SGWirelessDocs.pdf" "$OUTDIR/$TAG/_static/SGWirelessDocs.pdf"

    # Store cache for future builds (non-latest versions only)
    if [[ "$SHOULD_CACHE" == "true" ]]; then
        store_cached_build "$TAG" "$COMMIT_HASH" || true  # Don't fail build if cache storage fails
    fi

    if [[ "$WORKDIR" != "$SRCDIR" ]]; then
        rm -rf "$WORKDIR"
    fi
done

# -------------------------------------------------------------------
# Root redirect → latest version (absolute URL so it can't accumulate
# when Amplify rewrites a 404 to this page while keeping the URL).
# -------------------------------------------------------------------
cat > "$OUTDIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url=/${LATEST}/index.html">
  <title>Redirecting…</title>
</head>
<body>
  <p>Redirecting to <a href="/${LATEST}/index.html">${LATEST}</a>…</p>
</body>
</html>
EOF

# -------------------------------------------------------------------
# Stable, version-independent downloads.
# Files placed in _static/downloads are also published at the site root
# under /downloads/<name> so external sites can link to a permanent URL
# that does not change when the latest version bumps.
# -------------------------------------------------------------------
if [[ -d "$SRCDIR/_static/downloads" ]]; then
    mkdir -p "$OUTDIR/downloads"
    cp -r "$SRCDIR/_static/downloads/." "$OUTDIR/downloads/"
    echo "Published stable downloads to $OUTDIR/downloads"
fi

echo ""
echo "=== Done — output in $OUTDIR ==="
echo "    Latest: $LATEST"
echo "    Versions: ${TAGS[*]}"
if [[ $CACHED_COUNT -gt 0 || $BUILT_COUNT -gt 0 ]]; then
    echo "    Built: $BUILT_COUNT  |  Cached: $CACHED_COUNT"
fi
