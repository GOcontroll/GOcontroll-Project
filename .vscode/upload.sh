#!/bin/bash
# Uploads the build output to the controller using the correct method
# for the currently selected target.

TARGET=$(cat .vscode/current_target 2>/dev/null || echo "linux")

case "$TARGET" in
    "linux")
        IP=$(grep -oP '"gocontroll\.controllerIP":\s*"\K[^"]+' .vscode/settings.json 2>/dev/null || echo "192.168.1.19")
        exec make upload IP="$IP"
        ;;
    "iot")
        exec python.exe $(wslpath -w tools/send_firmware.py) $(wslpath -w build_iot/app.srec)
        ;;
    *)
        echo "Error: Unknown target '$TARGET'."
        echo "Click the 'Linux' or 'IoT' button in the status bar first."
        exit 1
        ;;
esac
