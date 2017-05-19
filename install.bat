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
copy LICENSE.mintty "%installdir%"
copy LICENSE.wslbridge "%installdir%"

echo @echo off> setdirs.bat
echo set refinstalldir=%refinstalldir%>> setdirs.bat
echo set installdir=%installdir%>> setdirs.bat
echo set refconfigdir=%refconfigdir%>> setdirs.bat
echo set configdir=%configdir%>> setdirs.bat
copy setdirs.bat + wsl.bat "%installdir%\wsl.bat"
copy setdirs.bat + wsl~.bat "%installdir%\wsl~.bat"
copy setdirs.bat + wsl-l.bat "%installdir%\wsl-l.bat"
copy setdirs.bat + uninstall.bat "%installdir%\uninstall.bat"
copy setdirs.bat + config-context-menu.bat "%installdir%\config-context-menu.bat"

copy "add to context menu.lnk" "%installdir%"
copy "remove from context menu.lnk" "%installdir%"

mkdir "%installdir%\bin"
copy cygwin1.dll "%installdir%\bin"
copy cygwin-console-helper.exe "%installdir%\bin"
rem copy dash.exe "%installdir%\bin"
copy mintty.exe "%installdir%\bin"
copy zoo.exe "%installdir%\bin"
copy wslbridge.exe "%installdir%\bin"
copy wslbridge-backend "%installdir%\bin"

rem create system config directory and copy config archive
mkdir "%installdir%\usr\share\mintty\lang"
copy po.zoo "%installdir%\usr\share\mintty\lang"


:shortcuts

rem generate shortcuts

set icon=%%LOCALAPPDATA%%\lxss\bash.ico
set target=%refinstalldir%\bin\mintty.exe
set minttyargs=--wsl --configdir="%refconfigdir%" -o Locale=C -o Charset=UTF-8 /bin/wslbridge 
set bridgeargs=-t /bin/bash
cscript mkshortcut.vbs "/name:WSL Bash %% in Mintty"
set bridgeargs=-C~ -t /bin/bash
cscript mkshortcut.vbs "/name:WSL Bash ~ in Mintty"
set bridgeargs=-t /bin/bash -l
cscript mkshortcut.vbs "/name:WSL Bash -l in Mintty"

rem create Start Menu Folder
set smf=%APPDATA%\Microsoft\Windows\Start Menu\Programs\WSLtty
mkdir "%smf%"
copy "wsltty home & help.url" "%smf%"
copy "WSL Bash %% in Mintty.lnk" "%smf%"
copy "WSL Bash ~ in Mintty.lnk" "%smf%"
copy "WSL Bash -l in Mintty.lnk" "%smf%"
mkdir "%smf%\context menu shortcuts"
copy "add to context menu.lnk" "%smf%\context menu shortcuts"
copy "remove from context menu.lnk" "%smf%\context menu shortcuts"

rem create Desktop Shorcuts
copy "WSL Bash %% in Mintty.lnk" "%USERPROFILE%\Desktop"
copy "WSL Bash ~ in Mintty.lnk" "%USERPROFILE%\Desktop"


:sysconfig

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


:end
