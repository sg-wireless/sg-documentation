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

    # Copy templates and static that live on the current branch
    # (so the version flyout is always up-to-date)
    cp -r "$SRCDIR/_templates" "$WORKDIR/_templates"
    cp -r "$SRCDIR/_static" "$WORKDIR/_static"
    cp "$SRCDIR/conf.py" "$WORKDIR/conf.py"

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
