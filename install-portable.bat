@echo off

echo Installing WSL Terminal Portable
echo Select target folder in popup dialog ...

set sel="Select folder to place installation of portable wsltty"

for /f "usebackq delims=" %%f in (`powershell "(new-object -COM Shell.Application).BrowseForFolder(0, '%sel%', 0, 0).self.path"`) do set f=%%f
set instdir=%f%\wsltty
if exist %f%\LICENSE.mintty set instdir=%f%

if "%f%"=="" (
	echo no installation
	exit
) else if not exist "%f%" (
	echo invalid installation folder %instdir%
	exit
)

rem call main installation
call install "%instdir%" "%instdir%" /P

rem create shortcut
set instpath=%instdir:~2%
cd /D "%instpath%"
set target=%%COMSPEC%%
set minttyargs=/C bin\mintty.exe --WSL= --icon=/wsl.ico --configdir=. -~
set bridgeargs= -
rem set wdir=%instpath%
rem let mkshortcut set working directory to empty:
set wdir=.
set icon=%instpath%\wsl.ico
cscript /nologo mkshortcut.vbs "/name:WSL Terminal Portable"

