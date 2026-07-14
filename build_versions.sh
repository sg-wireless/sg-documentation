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

# -------------------------------------------------------------------
# Branch detection: on non-main branches, build only the current
# working tree as a preview (no tag checkout, no multi-version).
# This lets Amplify preview deployments show uncommitted / untagged
# changes from feature branches.
# -------------------------------------------------------------------
CURRENT_BRANCH="${AWS_BRANCH:-$(git -C "$SRCDIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)}"

if [[ "$CURRENT_BRANCH" != "main" ]]; then
  PREVIEW_TAG="preview"
  PREVIEW_VERSION="preview"
  if [[ "$CURRENT_BRANCH" =~ ^release/(v[0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
    PREVIEW_VERSION="${BASH_REMATCH[1]}"
  fi
    echo "=== Preview build for branch '$CURRENT_BRANCH' (single version) ==="

    rm -rf "$OUTDIR"
    mkdir -p "$OUTDIR"

    ALL_JSON="[\"$PREVIEW_VERSION\"]"

    SGW_CURRENT_VERSION="$PREVIEW_VERSION" \
    SGW_ALL_VERSIONS="$ALL_JSON" \
    sphinx-build -b html -j auto "$SRCDIR" "$OUTDIR/$PREVIEW_TAG"

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

    # Copy templates, static, config, and homepage from the current branch
    # (so the version flyout and homepage are always up-to-date)
    cp -r "$SRCDIR/_templates" "$WORKDIR/_templates"
    cp -r "$SRCDIR/_static" "$WORKDIR/_static"
    cp "$SRCDIR/conf.py" "$WORKDIR/conf.py"
    cp "$SRCDIR/index.rst" "$WORKDIR/index.rst"

    SGW_CURRENT_VERSION="$TAG" \
    SGW_ALL_VERSIONS="$ALL_JSON" \
    sphinx-build -b html -j auto "$WORKDIR" "$OUTDIR/$TAG"

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
