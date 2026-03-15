#!/bin/bash
# Stores the selected target and updates IntelliSense configuration.
# Usage: set_target.sh <linux|iot>

TARGET="$1"

if [ "$TARGET" != "linux" ] && [ "$TARGET" != "iot" ]; then
    echo "Error: Unknown target '$TARGET'. Use 'linux' or 'iot'."
    exit 1
fi

echo "$TARGET" > .vscode/current_target

if [ "$TARGET" = "linux" ]; then
    LINUX_ICON='$(pass-filled)'
    IOT_ICON='$(circle-large-outline)'
else
    LINUX_ICON='$(circle-large-outline)'
    IOT_ICON='$(pass-filled)'
fi

cat > .vscode/tasks.json << EOF
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "$LINUX_ICON Linux",
            "type": "shell",
            "command": "bash .vscode/set_target.sh linux",
            "problemMatcher": [],
            "presentation": { "reveal": "silent", "panel": "shared" }
        },
        {
            "label": "$IOT_ICON IoT",
            "type": "shell",
            "command": "bash .vscode/set_target.sh iot",
            "problemMatcher": [],
            "presentation": { "reveal": "silent", "panel": "shared" }
        },
        {
            "label": "\$(tools) Build",
            "type": "shell",
            "command": "bash .vscode/build.sh",
            "group": { "kind": "build", "isDefault": true },
            "problemMatcher": "\$gcc"
        },
        {
            "label": "\$(cloud-upload) Upload",
            "type": "shell",
            "command": "bash .vscode/upload.sh",
            "problemMatcher": [],
            "presentation": { "reveal": "always", "panel": "shared" }
        },
        {
            "label": "\$(trash) Clean",
            "type": "shell",
            "command": "bash .vscode/clean.sh",
            "problemMatcher": [],
            "presentation": { "reveal": "always", "panel": "shared" }
        }
    ]
}
EOF

if [ "$TARGET" = "linux" ]; then
cat > .vscode/c_cpp_properties.json << 'EOF'
{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "${workspaceFolder}/application",
                "${workspaceFolder}/GOcontroll-CodeBase/code",
                "${workspaceFolder}/GOcontroll-CodeBase/code/modules",
                "${workspaceFolder}/GOcontroll-CodeBase/lib/IIO",
                "${workspaceFolder}/GOcontroll-CodeBase/lib/JSON-C",
                "${workspaceFolder}/GOcontroll-CodeBase/lib/OAES"
            ],
            "defines": [ "GOCONTROLL_LINUX", "_GNU_SOURCE", "DEBUG=0" ],
            "compilerPath": "/usr/bin/aarch64-linux-gnu-gcc",
            "cStandard": "gnu11",
            "intelliSenseMode": "linux-gcc-arm64"
        }
    ],
    "version": 4
}
EOF
else
cat > .vscode/c_cpp_properties.json << 'EOF'
{
    "configurations": [
        {
            "name": "IoT",
            "includePath": [
                "${workspaceFolder}/application",
                "${workspaceFolder}/GOcontroll-CodeBase/code",
                "${workspaceFolder}/GOcontroll-CodeBase/code/modules",
                "${workspaceFolder}/GOcontroll-CodeBase/code/iot/Core/Inc",
                "${workspaceFolder}/GOcontroll-CodeBase/code/iot/Drivers/CMSIS/Include",
                "${workspaceFolder}/GOcontroll-CodeBase/code/iot/Drivers/CMSIS/Device/ST/STM32H5xx/Include",
                "${workspaceFolder}/GOcontroll-CodeBase/code/iot/Drivers/STM32H5xx_HAL_Driver/Inc",
                "${workspaceFolder}/GOcontroll-CodeBase/code/iot/Drivers/STM32H5xx_HAL_Driver/Inc/Legacy",
                "${workspaceFolder}/GOcontroll-CodeBase/code/iot/Drivers/segger/Inc",
                "${workspaceFolder}/GOcontroll-CodeBase/code/iot/Middlewares/Third_Party/FreeRTOS/Source/include",
                "${workspaceFolder}/GOcontroll-CodeBase/code/iot/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2",
                "${workspaceFolder}/GOcontroll-CodeBase/code/iot/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM33_NTZ/non_secure"
            ],
            "defines": [ "GOCONTROLL_IOT", "STM32H573xx", "USE_HAL_DRIVER", "DEBUG=0" ],
            "compilerPath": "/usr/bin/arm-none-eabi-gcc",
            "cStandard": "gnu11",
            "intelliSenseMode": "linux-gcc-arm"
        }
    ],
    "version": 4
}
EOF
fi

echo "Target set to: $TARGET"
