rem @echo off

rem If you change the installation directory,
rem it also needs to be adapted in
rem - the Shortcut links *.lnk
rem - the cmd invocation scripts wsl*.bat
set installdir=%LOCALAPPDATA%\wsltty


:deploy

mkdir "%installdir%"
copy LICENSE.mintty "%installdir%"
copy LICENSE.wslbridge "%installdir%"
copy uninstall.bat "%installdir%"

copy wsl.bat "%installdir%"
copy wsl~.bat "%installdir%"
rem does not work without admin rights:
rem copy wsl.bat "%SYSTEMROOT%\System32"
rem copy wsl~.bat "%SYSTEMROOT%\System32"

mkdir "%installdir%\bin"
copy cygwin1.dll "%installdir%\bin"
copy cygwin-console-helper.exe "%installdir%\bin"
rem copy dash.exe "%installdir%\bin"
copy mintty.exe "%installdir%\bin"
copy wslbridge.exe "%installdir%\bin"
copy wslbridge-backend "%installdir%\bin"

rem create "home directory" to enable storage of config file
mkdir "%installdir%\home
mkdir "%installdir%\home\%USERNAME%"


:shortcuts

rem create Desktop Shorcut
copy "Bash on UoW in Mintty.lnk" "%USERPROFILE%\Desktop"
copy "Bash ~ on UoW in Mintty.lnk" "%USERPROFILE%\Desktop"

rem create Start Menu Shortcut
copy "Bash on UoW in Mintty.lnk" "%APPDATA%\Microsoft\Windows\Start Menu"
copy "Bash ~ on UoW in Mintty.lnk" "%APPDATA%\Microsoft\Windows\Start Menu"


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
