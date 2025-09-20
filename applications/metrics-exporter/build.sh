#!/bin/bash

# Define the source file and output executable name
SOURCE_FILE="main.go"
OUTPUT_EXECUTABLE="main"
OUTPUT_DIR="../../ansible/roles/metrics-exporter/files"

echo "Building the Golang application for amd64 Linux..."

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Set the environment variables for cross-compilation to Linux AMD64
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o "$OUTPUT_DIR/$OUTPUT_EXECUTABLE" "$SOURCE_FILE"
chmod +x $OUTPUT_DIR/$OUTPUT_EXECUTABLE

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Build successful! Executable is located at $OUTPUT_DIR/$OUTPUT_EXECUTABLE"
else
    echo "Build failed."
fi