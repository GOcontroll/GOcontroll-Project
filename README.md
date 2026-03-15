# GOcontroll-Project
Project to start developing your application on a Linux based GOcontroll Moduline controller (Native compilation on target) or building an application in Visual Studio Code.

### How to start
It is advisable to clone or download our GOcontroll-Project as an example into your own repository or when you're working without software management, download into your local folder. GOcontroll-Project is just a template environment and **relies fully on the GOcontroll-CodeBase repository** which needs to be added as a submodule.

## Submodule
Before start developing your application, the GOcontroll-CodeBase submodule needs to be cloned into your project folder.

### Add your submodule for the first time
In the root of your repository, add the submodule for the first time.  
`git submodule add https://github.com/GOcontroll/GOcontroll-CodeBase.git GOcontroll-CodeBase`

The new folder structure should look like:
```
GOcontroll-Project/
├── GOcontroll-CodeBase/    ← submodule (with examples)
├── application/
│   └── main.c              ← your application
├── Makefile
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
`./build/app` 

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

### Step 3 — Install VS Code extensions
Install the following extensions in Visual Studio Code:
- **WSL** (Microsoft) — connects VS Code to your WSL environment
- **C/C++** (Microsoft) — IntelliSense, syntax highlighting and code navigation
- **Makefile Tools** (Microsoft) — target selector panel with build configurations
- **Tasks** (actboy168) — shows build and upload buttons in the status bar

### Step 4 — Open your project in WSL
In VS Code, open the Command Palette (`Ctrl+Shift+P`) and select:
`WSL: Open Folder in WSL`

Navigate to your project folder. VS Code will reopen and all tools will now run inside WSL.

> **Important:** VS Code always connects to the **default** WSL distribution. If you have multiple distributions installed, make sure the correct one is set as default. Check your current default:
> `wsl --list --verbose`
> The default is marked with a `*`. To change it:
> `wsl --set-default <distro-name>`

### Step 5 — Build
Select your target in the **Makefile Tools panel** (left sidebar) under **Configuration**:
- Moduline IV
- Moduline Mini
- Moduline Display
- Moduline IOT

Then click the **Build** button in the status bar at the bottom of VS Code. The build output is located at `build/app.elf`.

### Step 6 — Deploy to controller
When you are connected to your controller using Wi-Fi - AP or ethernet connectivity, you can upload the generated bianry directly to you controller. First, set your controller's IP address in:   `.vscode/settings.json`:
```json
"gocontroll.controllerIP": "192.168.1.19"
```

Click the **Upload** button in the status bar to upload `build/app.elf` to the controller. The upload uses the `go-upload-server` running on the controller at port `8001`.

## Further reading
For more information on starting and managing services on the controller, visit the GOcontroll knowledge base:
[GOcontroll Services — go-simulink](https://gocontroll.com/knowledge-base/configuration/gocontroll-services/go-simulink/)