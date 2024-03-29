@echo off

set sel="Select folder to place installation of portable wsltty"

for /f "usebackq delims=" %%f in (`powershell "(new-object -COM Shell.Application).BrowseForFolder(0, '%sel%', 0, 0).self.path"`) do set f=%%f
set instdir=%f%\wsltty

if "%f%"=="" (
	echo no installation
	exit
) else if not exist "%f%" (
	echo invalid installation folder %instdir%
	exit
)

call install "%instdir%" "%instdir%" /P

rem create shortcut
cd /D "%instdir%"
set instpath=%instdir:~2%
set target=%%COMSPEC%%
set minttyargs=/C bin\mintty.exe --WSL= --icon=/wsl.ico --configdir=. -~
set bridgeargs= -
set wdir=%instpath%
set icon=%instpath%\wsl.ico
cscript /nologo mkshortcut.vbs "/name:WSL Terminal Portable"

