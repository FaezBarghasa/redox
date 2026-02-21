#!/usr/bin/env bash
# image-gen.sh
# Automates image generation for Nano/Pro/Titan profiles

set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/image-gen.sh <profile>"
    echo "Profiles: nano-esp32, full-workstation, server, etc."
    exit 1
fi

PROFILE=$1

echo "========================================="
echo "   Redox OS Image Generator: $PROFILE    "
echo "========================================="

# Ensure we're in the redox checkout directory
if [ ! -d ".git" ] || [ ! -d "build" ]; then
    echo "Error: Not in the redox project root. Must run from the root directory."
    exit 1
fi

echo "Initiating build for CONFIG_NAME=$PROFILE..."
make build/img/livedisk.iso CONFIG_NAME="$PROFILE"

mkdir -p dist
if [ -f "build/img/livedisk.iso" ]; then
    cp build/img/livedisk.iso "dist/${PROFILE}-livedisk.iso"
    echo "Generated dist/${PROFILE}-livedisk.iso"
fi

if [ -f "build/img/harddrive.bin" ]; then
    cp build/img/harddrive.bin "dist/${PROFILE}-harddrive.bin"
    echo "Generated dist/${PROFILE}-harddrive.bin"
fi

echo "Image generation complete for $PROFILE"
