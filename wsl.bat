@echo off

rem Start mintty terminal for WSL in home directory

rem To enable invocation of this script from WIN+R or from cmd.exe,
rem you may want to copy this script into "%SYSTEMROOT%\System32"

rem You may want a variant of this script without trailing "-l" 
rem to start in the current directory from cmd.exe

"%LOCALAPPDATA%\wsltty\bin\mintty.exe" -o Locale=C -o Charset=UTF-8 -i "%LOCALAPPDATA%\lxss\bash.ico" /bin/wslbridge -t /bin/bash -l

