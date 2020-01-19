@echo off

if "%installdir%" == "" set installdir="%LOCALAPPDATA%\wsltty"


:shortcuts

rem delete Start Menu Folder
set smf="%APPDATA%\Microsoft\Windows\Start Menu\Programs\WSLtty"
rmdir /S /Q "%smf%"


:start menu

cd %installdir%
bin\dash.exe config-distros.sh -shortcuts-remove


:explorer context menu

cd %installdir%
bin\dash.exe config-distros.sh -contextmenu-remove


:undeploy

cd %installdir%
rem currently not removing software


:end
