# GOcontroll-Project
Project to start developing your application on a Linux based GOcontroll Moduline controller (Native compilation on target) or building an application in Visual Studio Code.

### How to start
It is advisable to clone or download our GOcontroll-Project as an example into your own repository or when you're working without software management, download into your local folder. GOcontroll-Project is just a template environment and **relies fully on the GOcontroll-CodeBase repository** which needs to be added as a submodule.

## Submodule
Before start developing your application, the GOcontroll-CodeBase submodule needs to be cloned into your project folder. Because our repository already has implemende GOcontroll-CodeBase, The submodule only has to be initially updated with command:  
`git submodule update --init --recursive`

When you build your own project from a clean repository, you first have to add the sub module with command:  
`git submodule add https://github.com/GOcontroll/GOcontroll-CodeBase.git GOcontroll-CodeBase`

The new folder structure should look like:
```
GOcontroll-Project/
├── .vscode/                ← VS Code configuration (tasks, build, upload scripts)
├── GOcontroll-CodeBase/    ← submodule (with examples)
├── application/
│   └── main.c              ← your application
├── tools/                  ← host-side utilities (BLE upload script)
├── Makefile                ← build rules for Moduline IV / Mini / Display
├── Makefile_iot            ← build rules for Moduline IOT
└── README.md
```

### Update the submodule
When you have touched the submodule and want to pull the latest version, discarding your changes, just execute:  
`git submodule update --remote --force`

## Build and run on your Linux based controller
When your complete project is placed on the controller (e.g. /home/GOcontroll-Project) You can simply build your *application/main.c* with the command:  
`make`  

If you want to build one of the examples. (e.g. *led_blink.c*) execute the following command:  
`make led_blink`  

All make commands will result in an executable binary named *app* To run this binary simply execute the command:  
`./build/app.elf` 

## Build, deploy and run from a Windows host (building with VSC)
Building from Windows is done using **WSL (Windows Subsystem for Linux)** combined with the **WSL** extension in Visual Studio Code. WSL provides a real Linux environment alongside Windows — without a virtual machine. All compilation runs inside WSL while you use VS Code normally in Windows.

### Step 1 — Install WSL
Open PowerShell as Administrator and run:
`wsl --install`

This installs Ubuntu by default. Any Linux distribution (Ubuntu, Debian, etc.) will work as long as it supports `apt`.

Restart your PC when prompted. On first launch, set a username and password for your WSL environment.


After installation there are three ways to open WSL:
- **Start menu** — search for *Ubuntu* and open it
- **Terminal / PowerShell** — type `wsl`
- **VS Code** — `Ctrl+Shift+P` → `WSL: Open Folder in WSL` (recommended, no separate WSL window needed)

### Step 2 — Install the required packages
Open your WSL terminal and install the following packages:
```bash
sudo apt update
sudo apt install gcc-aarch64-linux-gnu gcc-arm-none-eabi make curl
```

For **Moduline IOT** BLE upload, install Python and the `bleak` BLE library on **Windows** (not WSL — Bluetooth runs on Windows):
```
pip install bleak
```
> Python for Windows can be downloaded from [python.org](https://www.python.org/downloads/).

### Step 3 — Install local VS Code extensions
Install the following extensions in VS Code on Windows. These are UI extensions that run locally:
- **WSL** (Microsoft) — connects VS Code to your WSL environment
- **Tasks** (actboy168) — shows target, build and upload buttons in the status bar

### Step 4 — Open your project in WSL
In VS Code, open the Command Palette (`Ctrl+Shift+P`) and select:
`WSL: Open Folder in WSL`

Navigate to your project folder. VS Code will reopen connected to WSL — you will see **WSL: Debian** (or your distro) in the bottom-left corner.

> **Important:** VS Code always connects to the **default** WSL distribution. If you have multiple distributions installed, make sure the correct one is set as default. Check your current default:
> `wsl --list --verbose`
> The default is marked with a `*`. To change it:
> `wsl --set-default <distro-name>`

### Step 5 — Install remote VS Code extensions
With the project open in WSL, install the following extension **in the WSL remote context**. Go to the Extensions panel (`Ctrl+Shift+X`), search for the extension and click **Install in WSL**:
- **C/C++** (Microsoft) — IntelliSense, syntax highlighting and code navigation

This extension must run inside WSL to analyse your C code correctly. If you previously installed it locally only, you will see an **"Install in WSL: &lt;distro&gt;"** button next to it.

After installing, reload the window when prompted (`Ctrl+Shift+P` → `Reload Window`).

### Step 6 — Select a target and build
The status bar at the bottom of VS Code shows four buttons:

| Button | Action |
|--------|--------|
| **Linux** | Switch to Moduline IV / Mini / Display target |
| **IoT** | Switch to Moduline IOT target |
| **Build** | Compile the project for the selected target |
| **Upload** | Deploy the binary to the controller |
| **Clean** | Remove the build output directory of the selected target |

Click **Linux** or **IoT** to select your target. This updates IntelliSense so only the relevant code is highlighted. Then click **Build**. The build output is located at `build/app.elf` (Linux) or `build_iot/app.srec` (IoT).

### Step 7 — Deploy to controller

**Moduline IV / Mini / Display — upload via Wi-Fi or Ethernet**

Make sure you are connected to the controller via Wi-Fi AP or Ethernet. Set the controller IP address in `.vscode/settings.json`:
```json
"gocontroll.controllerIP": "192.168.1.19"
```
Click the **Upload** button in the status bar. The binary `build/app.elf` is uploaded to the controller via the `go-upload-server` on port `8001`.

**Moduline IOT — upload via Bluetooth (BLE)**

Make sure the Moduline IOT is powered on and advertising as `GOcontroll-IoT`. Click the **Upload** button in the status bar. The script automatically scans for the device, transfers `build_iot/app.srec` in chunks and triggers the STM32 flash procedure via the ESP32 bootloader.

> The BLE upload runs on Windows (not WSL) because Bluetooth is a Windows resource. Python and `bleak` must be installed on Windows (see Step 2).

## Further reading
For more information on starting and managing services on the controller, visit the GOcontroll knowledge base:
[GOcontroll Services — go-simulink](https://gocontroll.com/knowledge-base/configuration/gocontroll-services/go-simulink/)