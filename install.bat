@echo off

set refinstalldir=%%LOCALAPPDATA%%\wsltty
set refconfigdir=%%APPDATA%%\wsltty
if "%installdir%" == "" set installdir="%LOCALAPPDATA%\wsltty"
if "%configdir%" == "" set configdir="%APPDATA%\wsltty"
call dequote installdir
call dequote configdir
set oldroot="%installdir%"
set oldhomedir="%installdir%\home\%USERNAME%"
call dequote oldroot
call dequote oldhomedir
set oldconfigdir="%oldhomedir%\.config\mintty"
call dequote oldconfigdir

rem override installdir, configdir if parameters given
set arg1=%1
call dequote arg1
if "%arg1%" == "%%arg1%%" goto deploy
set refinstalldir=%arg1%
set installdir=%arg1%
set arg2=%2
call dequote arg2
if "%arg2%" == "%%arg2%%" goto deploy
set refconfigdir=%arg2%
set configdir=%arg2%

:deploy

mkdir "%installdir%" 2> nul:

rem clean up previous installation artefacts
del /Q "%installdir%\*.bat"
del /Q "%installdir%\*.lnk"

copy LICENSE.mintty "%installdir%"
copy LICENSE.wslbridge2 "%installdir%"

copy "add to context menu.lnk" "%installdir%"
copy "add default to context menu.lnk" "%installdir%"
copy "remove from context menu.lnk" "%installdir%"
copy "configure WSL shortcuts.lnk" "%installdir%"
rem copy "WSL Terminal.lnk" "%installdir%"
rem copy "WSL Terminal %%.lnk" "%installdir%"
copy config-distros.sh "%installdir%"

copy mkshortcut.vbs "%installdir%"
copy cmd2.bat "%installdir%"
copy dequote.bat "%installdir%"

rem allow persistent customization of default icon:
if not exist "%installdir%\wsl.ico" copy tux.ico "%installdir%\wsl.ico"

copy uninstall.bat "%installdir%"

if not exist "%installdir%\bin" goto instbin
rem move previous programs possibly in use out of the way
del /Q "%installdir%\bin\*.old" 2> nul:
ren "%installdir%\bin\cygwin1.dll" cygwin1.dll.old
ren "%installdir%\bin\cygwin-console-helper.exe" cygwin-console-helper.exe.old
ren "%installdir%\bin\mintty.exe" mintty.exe.old
ren "%installdir%\bin\wslbridge2.exe" wslbridge2.exe.old
ren "%installdir%\bin\wslbridge2-backend" wslbridge2-backend.old
del /Q "%installdir%\bin\*.old" 2> nul:

:instbin
mkdir "%installdir%\bin" 2> nul:
copy cygwin1.dll "%installdir%\bin"
copy cygwin-console-helper.exe "%installdir%\bin"
copy mintty.exe "%installdir%\bin"
copy wslbridge2.exe "%installdir%\bin"
copy wslbridge2-backend "%installdir%\bin"

copy dash.exe "%installdir%\bin"
copy regtool.exe "%installdir%\bin"
copy zoo.exe "%installdir%\bin"

rem copy mkshortcut.exe "%installdir%"\bin
rem copy cygpopt-0.dll "%installdir%"\bin
rem copy cygiconv-2.dll "%installdir%"\bin
rem copy cygintl-8.dll "%installdir%"\bin

rem create system config directory and copy config archive and scripts
mkdir "%installdir%\usr\share\mintty\lang" 2> nul:
copy lang.zoo "%installdir%\usr\share\mintty\lang"
mkdir "%installdir%\usr\share\mintty\themes" 2> nul:
copy themes.zoo "%installdir%\usr\share\mintty\themes"
mkdir "%installdir%\usr\share\mintty\sounds" 2> nul:
copy sounds.zoo "%installdir%\usr\share\mintty\sounds"
mkdir "%installdir%\usr\share\mintty\info" 2> nul:
copy charnames.txt "%installdir%\usr\share\mintty\info"
mkdir "%installdir%\usr\share\mintty\icon" 2> nul:
copy tux.ico "%installdir%\usr\share\mintty\icon"
copy mintty.ico "%installdir%\usr\share\mintty\icon"
mkdir "%installdir%\usr\share\mintty\emojis" 2> nul:
copy getemojis "%installdir%\usr\share\mintty\emojis" 2> nul:
copy getflags "%installdir%\usr\share\mintty\emojis" 2> nul:
mkdir "%installdir%\usr\share\terminfo" 2> nul:
copy terminfo.zoo "%installdir%\usr\share\terminfo"


rem create Start Menu Folder
set smf="%APPDATA%\Microsoft\Windows\Start Menu\Programs\WSLtty"
call dequote smf
mkdir "%smf%" 2> nul:

rem clean up previous installation
del /Q "%smf%\*.lnk"

copy "wsltty home & help.url" "%smf%"
copy "add to context menu.lnk" "%smf%"
copy "add default to context menu.lnk" "%smf%"
copy "remove from context menu.lnk" "%smf%"
copy "configure WSL shortcuts.lnk" "%smf%"
rem copy "WSL Terminal.lnk" "%smf%"
rem copy "WSL Terminal %%.lnk" "%smf%"
rem clean up previous installation
rmdir /S /Q "%smf%\context menu shortcuts" 2> nul:

rem unpack config files in system config directory
cd /D "%installdir%\usr\share\mintty\lang"
"%installdir%\bin\zoo" xO lang
cd /D "%installdir%\usr\share\mintty\themes"
"%installdir%\bin\zoo" xO themes
cd /D "%installdir%\usr\share\mintty\sounds"
"%installdir%\bin\zoo" xO sounds
cd /D "%installdir%\usr\share\terminfo"
"%installdir%\bin\zoo" xO terminfo
cd /D "%installdir%"


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
rmdir "%oldhomedir%" 2> nul:
rmdir "%oldroot%\home" 2> nul:


:userconfig

rem create user config directory and subfolders, copy scripts
mkdir "%configdir%\lang" 2> nul:
mkdir "%configdir%\themes" 2> nul:
mkdir "%configdir%\sounds" 2> nul:
mkdir "%configdir%\emojis" 2> nul:
copy "%installdir%\usr\share\mintty\emojis\getemojis" "%configdir%\emojis" 2> nul:
copy "%installdir%\usr\share\mintty\emojis\getflags" "%configdir%\emojis" 2> nul:

goto noetc
rem 3.8.0.2: create global config file for troubleshooting
mkdir "%installdir%\etc" 2> nul:
echo ###########################>"%installdir%\etc\minttyrc"
echo # Troubleshooting>>"%installdir%\etc\minttyrc"
echo # To work around a pty interworking issue between wsl and cygwin,>>"%installdir%\etc\minttyrc"
echo # we need to apply this configuration for now:>>"%installdir%\etc\minttyrc"
echo Baud=999999>>"%installdir%\etc\minttyrc"
goto etcok

:noetc
rem 3.8.0.3: remove previous troubleshooting patch
if exist "%installdir%\etc\minttyrc" del "%installdir%\etc\minttyrc"
if exist "%installdir%\etc" rmdir "%installdir%\etc"

:etcok


rem create config file if it does not yet exist
if exist "%configdir%\config" goto appconfig
echo # To use common configuration in %%APPDATA%%\mintty, simply remove this file>"%configdir%\config"
if "%3" == "/P" echo # Do not remove this file for WSLtty Portable>>"%configdir%\config"


:appconfig

rem skip configuration for WSLtty Portable
if "%3" == "/P" goto end

rem distro-specific stuff: shortcuts and launch scripts
cd /D "%installdir%"
echo Configuring for WSL distributions
bin\dash.exe "config-distros.sh"
rem rem bin\dash.exe "config-distros.sh" -contextmenu


:end
