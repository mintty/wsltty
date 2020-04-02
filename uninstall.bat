@echo off

if "%installdir%" == "" set installdir="%LOCALAPPDATA%\wsltty"
call dequote installdir


:shortcuts

rem delete Start Menu Folder
set smf="%APPDATA%\Microsoft\Windows\Start Menu\Programs\WSLtty"
call dequote smf
rmdir /S /Q "%smf%"


:start menu

cd /D "%installdir%"
bin\dash.exe config-distros.sh -shortcuts-remove


:explorer context menu

cd /D "%installdir%"
bin\dash.exe config-distros.sh -contextmenu-remove


:undeploy

cd /D "%installdir%"
rem currently not removing software


:end
