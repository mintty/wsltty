@echo off

:explorer context menu

rem delete Explorer context menu
set userdirname=HKEY_CURRENT_USER\Software\Classes\Directory\shell
set userdirpane=HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell

reg delete "%userdirname%\wsltty" /f
reg delete "%userdirpane%\wsltty" /f

:end
