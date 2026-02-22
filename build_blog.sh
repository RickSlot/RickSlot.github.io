#!/usr/bin/env bash
set -euo pipefail

POSTS_DIR="posts"
OUTPUT="posts.json"
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

count=0

for f in "$POSTS_DIR"/*.md; do
  [ -f "$f" ] || continue

  # Skip drafts
  draft=$(awk 'BEGIN{p=0} /^---/{p++; next} p==1 && /^draft:/{sub(/^draft:[[:space:]]*/, ""); print; exit} p==2{exit}' "$f")
  [ "$draft" = "true" ] && continue

  # Slug from filename (basename without .md)
  slug=$(basename "$f" .md)

  # Title and date from frontmatter
  title=$(awk 'BEGIN{p=0} /^---/{p++; next} p==1 && /^title:/{sub(/^title:[[:space:]]*/, ""); print; exit} p==2{exit}' "$f")
  date=$(awk 'BEGIN{p=0} /^---/{p++; next} p==1 && /^date:/{sub(/^date:[[:space:]]*/, ""); print; exit} p==2{exit}' "$f")

  # Skip posts missing required fields
  if [ -z "$title" ] || [ -z "$date" ]; then
    echo "Warning: skipping $f (missing title or date)" >&2
    continue
  fi

  # Excerpt: first non-empty, non-heading body line after frontmatter
  excerpt=$(awk 'BEGIN{p=0} /^---/{p++; next} p>=2 && /^#/{next} p>=2 && NF>0{print; exit}' "$f")

  # Body: everything after the closing ---
  body=$(awk 'BEGIN{p=0} /^---/{p++; next} p>=2{print}' "$f")

  # Append compact JSON entry to temp file
  jq -cn \
    --arg slug "$slug" \
    --arg title "$title" \
    --arg date "$date" \
    --arg excerpt "$excerpt" \
    --arg body "$body" \
    '{slug: $slug, title: $title, date: $date, excerpt: $excerpt, body: $body}' >> "$TMPFILE"

  count=$((count + 1))
done

# Sort by date descending and write output
if [ "$count" -eq 0 ]; then
  echo "[]" > "$OUTPUT"
else
  jq -s 'sort_by(.date) | reverse' "$TMPFILE" > "$OUTPUT"
fi

git add "$OUTPUT"
echo "✓ Generated $OUTPUT with $count post(s)"
