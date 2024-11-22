@echo off

chcp 65001 > nul

if not exist "WSL Terminal Portable.lnk" goto install
echo Rebuilding WSL Terminal Portable shortcut
set instdir=%~dp0
goto shortcut

:install

echo Installing WSL Terminal Portable
echo Select target folder in popup dialog ...

set sel="Select folder to place installation of portable wsltty"

for /f "usebackq delims=" %%f in (`powershell "(new-object -COM Shell.Application).BrowseForFolder(0, '%sel%', 0, 0).self.path"`) do set f=%%f
set instdir=%f%\wsltty
if exist %f%\LICENSE.mintty set instdir=%f%

if "%f%"=="" (
	echo No installation selected
	pause
	exit
) else if not exist "%f%" (
	echo Invalid installation folder %instdir%
	pause
	exit
)

rem call main installation
call install "%instdir%" "%instdir%" /P
rem this already changes into "%instdir%"

rem copy additional portable installation files
rem do this after call install as that deletes previous .bat files
copy "%~dp0\install-portable.bat" .
dir "%instdir%"\install-portable.bat

:shortcut

rem create shortcut
cd /D "%instdir%"
rem set drive-relative path for shortcut working directory and icon
set instpath=%instdir:~2%
set target=%%COMSPEC%%
set minttyargs=/C bin\mintty.exe --WSL= --icon=/wsl.ico --configdir=. -~
set bridgeargs= -
rem set wdir=%instpath%
rem let mkshortcut set working directory to empty:
set wdir=.
set icon=%instpath%\wsl.ico
cscript /nologo mkshortcut.vbs "/name:WSL Terminal Portable"

