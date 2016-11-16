@echo off

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
copy wsl-l.bat "%installdir%"
copy "add to context menu.bat" "%installdir%"
copy "remove from context menu.bat" "%installdir%"
rem does not work without admin rights:
rem copy wsl.bat "%SYSTEMROOT%\System32"
rem copy wsl~.bat "%SYSTEMROOT%\System32"
rem copy wsl-l.bat "%SYSTEMROOT%\System32"

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

rem create Start Menu Folder
set smf=%APPDATA%\Microsoft\Windows\Start Menu\Programs\WSLtty
mkdir "%smf%"
copy "wsltty home & help.url" "%smf%"
copy "WSL Bash % in Mintty.lnk" "%smf%"
copy "WSL Bash ~ in Mintty.lnk" "%smf%"
copy "WSL Bash -l in Mintty.lnk" "%smf%"
mkdir "%smf%\context menu shortcuts"

rem create Desktop Shorcuts
copy "WSL Bash % in Mintty.lnk" "%USERPROFILE%\Desktop"
copy "WSL Bash ~ in Mintty.lnk" "%USERPROFILE%\Desktop"


:end
