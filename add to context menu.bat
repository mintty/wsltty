@echo off

rem See comments in install.bat about changing the installation directory.

set installdir=%LOCALAPPDATA%\wsltty

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
set cmd=%installdir%\bin\mintty.exe
set cset=-o Locale=C -o Charset=UTF-8
set opts=--wsl
set arg=/bin/wslbridge -t %shell%
set target0=\"%cmd%\" %opts% %cset% -i \"%icon%\" %arg%
rem set target1=\"%cmd%\" %opts% %cset% -i \"%icon%\" /bin/dash -c \"cd '%%1'; exec %arg%\"
set target1=\"%cmd%\" %opts% %cset% -i \"%icon%\" --dir \"%%1\" %arg%

rem Registry entries
reg add "%userdirname%\wsltty" /d "%label% %here%" /f
reg add "%userdirname%\wsltty" /v Icon /d "%icon%" /f
reg add "%userdirname%\wsltty\command" /d "%target1%" /f
reg add "%userdirpane%\wsltty" /d "%label% %here%" /f
reg add "%userdirpane%\wsltty" /v Icon /d "%icon%" /f
reg add "%userdirpane%\wsltty\command" /d "%target0%" /f

:end
