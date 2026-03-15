#!/bin/bash
# Removes the build output directory for the currently selected target.
# Set the target first by clicking the Linux or IoT button in the status bar.

TARGET=$(cat .vscode/current_target 2>/dev/null || echo "linux")

case "$TARGET" in
    "linux")
        rm -rf build
        echo "Cleaned: build/"
        ;;
    "iot")
        rm -rf build_iot
        echo "Cleaned: build_iot/"
        ;;
    *)
        echo "Error: Unknown target '$TARGET'."
        exit 1
        ;;
esac
