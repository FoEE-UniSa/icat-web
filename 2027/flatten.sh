#!/bin/bash
# Post-build: move <name>.html/index.html up to <name>.html
# Hugo 0.144+ always emits content/<basename>/index.html, even when
# permalink ends in .html. This script flattens that to match the
# old PHP URL space (e.g., /calls.html instead of /calls.html/index.html).
#
# Works at any depth: /keynotes/speaker.html/index.html -> /keynotes/speaker.html
set -e
DIR="${1:-../html/2027}"

find "$DIR" -depth -type d -name '*.html' | while read -r subdir; do
    [ -f "$subdir/index.html" ] || continue
    parent=$(dirname "$subdir")
    base=$(basename "$subdir")
    tmp="$parent/__tmp_$base"
    mv "$subdir/index.html" "$tmp"
    rmdir "$subdir"
    mv "$tmp" "$parent/$base"
done
