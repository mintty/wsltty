@echo off

"%LOCALAPPDATA%\wsltty\bin\mintty.exe" -o Locale=C -o Charset=UTF-8 -i "%LOCALAPPDATA%\lxss\bash.ico" /bin/wslbridge -t /bin/bash -l

