#!/bin/bash

# Check if package name parameter was provided
if [ -z "$1" ]; then
  echo "Error: Package name is required as first parameter"
  echo "Usage: $0 PACKAGE_NAME [OUTPUT_FILE] [OPTIONS]"
  exit 1
fi

# Verify the package directory exists
PACKAGE_DIR="./packages/$1"
if [ ! -d "$PACKAGE_DIR" ]; then
  echo "Error: Package directory '$PACKAGE_DIR' does not exist"
  exit 2
fi

# Set default output file if not provided
OUTPUT_FILE="$2"
if [ -z "$OUTPUT_FILE" ]; then
  OUTPUT_FILE="$1.md"
  # Shift arguments to adjust for optional parameter
  shift 1
else
  # Shift arguments twice to maintain correct positioning for remaining args
  shift 2
fi

# Execute to_md.sh command with all arguments
./to_md.sh "$PACKAGE_DIR" "$OUTPUT_FILE" --include dart yaml sh --exclude '*.g.dart' '*.freezed.dart' 'app.*.dart' '*.form.dart' '*.mocks.dart' "$@"

# Check the execution status
if [ $? -eq 0 ]; then
  echo "Successfully processed $PACKAGE_DIR to $OUTPUT_FILE"
else
  echo "Error occurred while processing $PACKAGE_DIR"
  exit 4
fi