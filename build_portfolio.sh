#!/bin/bash

# This script generates a photos.json file and thumbnails based on the .jpg files found in the 'photos' directory.

PHOTO_DIR="photos"
THUMB_DIR="photos/thumbnails"
PHOTOS_JSON="photos.json"

# Check if the photos directory exists
if [ ! -d "$PHOTO_DIR" ]; then
    echo "Error: Photo directory '$PHOTO_DIR' not found." >&2
    exit 1
fi

# Create thumbnail directory if it doesn't exist
mkdir -p "$THUMB_DIR"

# Generate thumbnails
echo "Generating thumbnails..."
for file in "$PHOTO_DIR"/*.jpg; do
    if [ -f "$file" ]; then
        sips -Z 600 --setProperty formatOptions 95 "$file" --out "$THUMB_DIR/$(basename "$file")"
    fi
done

# Get list of .jpg files and format them for JSON array
# Handles cases where there are no .jpg files
echo "Generating photos.json..."
echo "[" > "$PHOTOS_JSON"
FIRST=true
for file in "$PHOTO_DIR"/*.jpg; do
    if [ -f "$file" ]; then
        FILENAME=$(basename "$file")
        # Get EXIF data as JSON
        EXIF_DATA=$(exiftool -json -ApertureValue -ShutterSpeedValue -ISO -FocalLength -DateTimeOriginal -ImageWidth -ImageHeight "$file")
        APERTURE=$(echo "$EXIF_DATA" | jq -r '.[0].ApertureValue')
        SHUTTER_SPEED=$(echo "$EXIF_DATA" | jq -r '.[0].ShutterSpeedValue')
        ISO=$(echo "$EXIF_DATA" | jq -r '.[0].ISO')
        FOCAL_LENGTH=$(echo "$EXIF_DATA" | jq -r '.[0].FocalLength')
        DATE_TAKEN=$(echo "$EXIF_DATA" | jq -r '.[0].DateTimeOriginal' | sed 's/:/-/g' | sed 's/ /T/')
        IMAGE_WIDTH=$(echo "$EXIF_DATA" | jq -r '.[0].ImageWidth')
        IMAGE_HEIGHT=$(echo "$EXIF_DATA" | jq -r '.[0].ImageHeight')

        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            echo "," >> "$PHOTOS_JSON"
        fi
        JSON_OBJECT="{\"filename\": \"$FILENAME\", \"aperture\": \"$APERTURE\", \"shutterSpeed\": \"$SHUTTER_SPEED\", \"iso\": \"$ISO\", \"focalLength\": \"$FOCAL_LENGTH\", \"dateTaken\": \"$DATE_TAKEN\", \"imageWidth\": \"$IMAGE_WIDTH\", \"imageHeight\": \"$IMAGE_HEIGHT\"}"
        echo -n "$JSON_OBJECT" >> "$PHOTOS_JSON"
    fi
done
echo "]" >> "$PHOTOS_JSON"

echo "Successfully generated $PHOTOS_JSON with photos from $PHOTO_DIR/"

# Add generated files to git
echo "Adding generated files to git..."
git add "$PHOTOS_JSON"
git add "$THUMB_DIR/"

echo "Successfully added generated files to git."