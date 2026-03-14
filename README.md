# GOcontroll-Project
Project to provide you with the basic setup to start developing C applications on GOcontroll hardware. This starter project can be used in Visual Studio Code with the proper compilers or directly on your Linux target.

### How to start
It is advisable to clone of download our GOcontroll-Project as an example into your own repositorie or when you're working without software management, download into you local folder. GOcontroll Project is just a template environment and **relies fully on the GOcontroll-CodeBase repositrie** Which needs to be added as submodule. 

### Pull/update submodules for the first time
In your repo:

`git submodule update --init --recursive`

This command will pull the codebase into your project. When everything went well, GOcontroll-CodeBase should be fully occupied with code, libraries and examples.

When you have touched the submodules and want to pull the latest version of the submodules, discaring your changes just execute:

`git submodule update --remote --force`


## Build an run on your Linux based controller
command `make` should start the compilation to build your code.

command `make led_blink` will compile the example *led_blink.c* from the example folder in GOcontroll-CodeBase.

All make commands will result in an executable binary named *app* To run this binary simply execute the command `./build/app` 

## Build, deploy and run from a Windows host (building with VSC)