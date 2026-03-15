#!/bin/bash
# Builds the project for the currently selected target.
# Set the target first by clicking the Linux or IoT button in the status bar.

TARGET=$(cat .vscode/current_target 2>/dev/null || echo "linux")

case "$TARGET" in
    "linux")
        exec make CC=aarch64-linux-gnu-gcc BUILD=build
        ;;
    "iot")
        exec make -f Makefile_iot BUILD=build_iot
        ;;
    *)
        echo "Error: Unknown target '$TARGET'."
        echo "Click the 'Linux' or 'IoT' button in the status bar first."
        exit 1
        ;;
esac
