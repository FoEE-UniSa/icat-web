#!/bin/bash
set -e
DIR="${1:-/tmp/test-flat}"
for subdir in "$DIR"/*.html; do
    if [ -d "$subdir" ]; then
        BASENAME=$(basename "$subdir")
        TMP="$DIR/__tmp_$BASENAME"
        mv "$subdir/index.html" "$TMP"
        rmdir "$subdir"
        mv "$TMP" "$subdir"
    fi
done
