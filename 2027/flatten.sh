#!/bin/bash
# Post-build: move <name>.html/index.html up to <name>.html
# Hugo 0.144+ always emits content/<basename>/index.html, even when
# permalink ends in .html. This script flattens that to match the
# old PHP URL space (e.g., /calls.html instead of /calls.html/index.html).
set -e
DIR="${1:-../html/2027}"
for subdir in "$DIR"/*.html; do
    if [ -d "$subdir" ]; then
        BASENAME=$(basename "$subdir")
        TMP="$DIR/__tmp_$BASENAME"
        mv "$subdir/index.html" "$TMP"
        rmdir "$subdir"
        mv "$TMP" "$subdir"
    fi
done
