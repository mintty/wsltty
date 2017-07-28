@echo off

rem Start mintty terminal for WSL in WSL home directory

if "%installdir%" == "" set installdir=%LOCALAPPDATA%\wsltty
if "%configdir%" == "" set configdir=%APPDATA%\wsltty

rem To enable invocation of this script from WIN+R or from cmd.exe,
rem you may want to copy this script into "%SYSTEMROOT%\System32",
rem or include the installation folder "%LOCALAPPDATA%\wsltty" in your PATH

"%installdir%\bin\mintty.exe" --wsl -h err "--configdir=%configdir%" -o Locale=C -o Charset=UTF-8 -i "%LOCALAPPDATA%\wsltty\wsl.ico" /bin/wslbridge -C~ -t /bin/bash

