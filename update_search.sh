#!/bin/sh
# Rebuilds the search index the search page loads from /_pagefind/.
# Run it after adding or editing posts, then commit static/_pagefind.
# The index comes from a clean build, so old files in public/ are never indexed.
set -e
cd "$(dirname "$0")"
site=$(mktemp -d)
trap 'rm -rf "$site"' EXIT
hugo --quiet --destination "$site"
pagefind --site "$site" --output-path "$site/_pagefind"
rm -rf static/_pagefind
cp -R "$site/_pagefind" static/_pagefind
