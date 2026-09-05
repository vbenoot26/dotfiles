#!/bin/bash
# Usage: piped-selection | helix-send-to-pi.sh <filename>
# Writes selection + filename metadata to ~/.pi/helix-context

FILENAME="$1"
OUTPUT_FILE="$HOME/.pi/helix-context"

# Read selection from stdin
SELECTION=$(cat)

# Write formatted output
{
    echo "// from file: $FILENAME"
    echo "$SELECTION"
} > "$OUTPUT_FILE"
