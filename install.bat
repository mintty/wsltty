@echo off


:deploy

mkdir "%LOCALAPPDATA%\wsltty"
copy LICENSE.mintty "%LOCALAPPDATA%\wsltty"
copy LICENSE.wslbridge "%LOCALAPPDATA%\wsltty"
copy uninstall.bat "%LOCALAPPDATA%\wsltty"

mkdir "%LOCALAPPDATA%\wsltty\bin"
copy cygwin1.dll "%LOCALAPPDATA%\wsltty\bin"
copy cygwin-console-helper.exe "%LOCALAPPDATA%\wsltty\bin"
copy mintty.exe "%LOCALAPPDATA%\wsltty\bin"
copy wslbridge.exe "%LOCALAPPDATA%\wsltty\bin"
copy wslbridge-backend "%LOCALAPPDATA%\wsltty\bin"

rem create "home directory" to enable storage of config file
mkdir "%LOCALAPPDATA%\wsltty\home
mkdir "%LOCALAPPDATA%\wsltty\home\%USERNAME%"


:shortcuts

rem create Desktop Shorcut
copy "Bash on UoW in Mintty.lnk" "%USERPROFILE%\Desktop"

rem create Start Menu Shortcut
copy "Bash on UoW in Mintty.lnk" "%APPDATA%\Microsoft\Windows\Start Menu"


:explorer

rem Explorer context menu
set userdirname=HKEY_CURRENT_USER\Software\Classes\Directory\shell
set userdirpane=HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell

rem WSL in Mintty
set label=WSL in Mintty
rem set here=in this directory
set here=Here

rem WSL icon
set icon=%LOCALAPPDATA%\lxss\bash.ico

rem WSL target shell
set shell=/bin/bash

rem Mintty invocation
set cmd=%LOCALAPPDATA%\wsltty\bin\mintty.exe
set arg=/bin/wslbridge -t %shell%
set target=\"%cmd%\" %arg%

reg add "%userdirname%\wsltty" /d "%label% %here%" /f
reg add "%userdirname%\wsltty" /v Icon /d "%icon%" /f
reg add "%userdirname%\wsltty\command" /d "%target%" /f
reg add "%userdirpane%\wsltty" /d "%label% %here%" /f
reg add "%userdirpane%\wsltty" /v Icon /d "%icon%" /f
reg add "%userdirpane%\wsltty\command" /d "%target%" /f


:end
