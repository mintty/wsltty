@echo off

set refinstalldir=%%LOCALAPPDATA%%\wsltty
set installdir=%LOCALAPPDATA%\wsltty
set refconfigdir=%%APPDATA%%\wsltty
set configdir=%APPDATA%\wsltty
set oldroot=%installdir%
set oldhomedir=%installdir%\home\%USERNAME%
set oldconfigdir=%oldhomedir%\.config\mintty
if not "%1" == "" set refinstalldir=%1 && set installdir=%1
if not "%2" == "" set refconfigdir=%2 && set configdir=%2


:deploy

mkdir "%installdir%"

rem clean up previous installation artefacts
del /Q "%installdir%\*.bat"
del /Q "%installdir%\*.lnk"

copy LICENSE.mintty "%installdir%"
copy LICENSE.wslbridge "%installdir%"

copy "add to context menu.lnk" "%installdir%"
copy "remove from context menu.lnk" "%installdir%"
copy "configure WSL shortcuts.lnk" "%installdir%"
copy wsl.ico "%installdir%"
copy config-distros.sh "%installdir%"
copy mkshortcut.vbs "%installdir%"

mkdir "%installdir%\bin"
copy cygwin1.dll "%installdir%\bin"
copy cygwin-console-helper.exe "%installdir%\bin"
copy dash.exe "%installdir%\bin"
copy regtool.exe "%installdir%\bin"
copy mintty.exe "%installdir%\bin"
copy zoo.exe "%installdir%\bin"
copy wslbridge.exe "%installdir%\bin"
copy wslbridge-backend "%installdir%\bin"

rem create system config directory and copy config archive
mkdir "%installdir%\usr\share\mintty\lang"
copy po.zoo "%installdir%\usr\share\mintty\lang"


rem create Start Menu Folder
set smf=%APPDATA%\Microsoft\Windows\Start Menu\Programs\WSLtty
mkdir "%smf%"

rem clean up previous installation
del /Q "%smf%\*.lnk"

copy "wsltty home & help.url" "%smf%"
copy "add to context menu.lnk" "%smf%"
copy "remove from context menu.lnk" "%smf%"
copy "configure WSL shortcuts.lnk" "%smf%"
rem clean up previous installation
rmdir /S /Q "%smf%\context menu shortcuts"

rem unpack config files in system config directory
cd /D "%installdir%\usr\share\mintty\lang"
"%installdir%\bin\zoo" xO po


:migrate configuration

rem migrate old config resource files to new config dir
if exist "%configdir%" goto configfile
if not exist "%oldconfigdir%" goto configfile
if exist "%oldhomedir%\.minttyrc" copy "%oldhomedir%\.minttyrc" "%oldconfigdir%\config" && del "%oldhomedir%\.minttyrc"
xcopy /E /I /Y "%oldconfigdir%" "%configdir%" && rmdir /S /Q "%oldconfigdir%"
rmdir "%oldhomedir%\.config"
:configfile
if exist "%configdir%\config" goto deloldhome
if exist "%oldhomedir%\.minttyrc" copy "%oldhomedir%\.minttyrc" "%configdir%\config" && del "%oldhomedir%\.minttyrc"
:deloldhome
rmdir "%oldhomedir%"
rmdir "%oldroot%\home"


:userconfig

rem create user config directory and subfolders
mkdir "%configdir%\lang"
mkdir "%configdir%\sounds"
mkdir "%configdir%\themes"

rem create config file if it does not yet exist
if not exist "%configdir%\config" echo # To use common configuration in %%APPDATA%%\mintty, simply remove this file>"%configdir%\config"

rem distro-specific stuff: shortcuts and launch scripts
cd "%installdir%"
bin\dash.exe "%installdir%\config-distros.sh"
rem bin\dash.exe "%installdir%\config-distros.sh" -contextmenu


:end
