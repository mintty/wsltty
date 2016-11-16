@echo off

rem See comments in install.bat about changing the installation directory.

set installdir=%LOCALAPPDATA%\wsltty


:shortcuts

rem delete Start Menu Folder
set smf=%APPDATA%\Microsoft\Windows\Start Menu\Programs\WSLtty
rmdir /S /Q "%smf%"

rem delete Desktop Shortcuts
del "%USERPROFILE%\Desktop\WSL Bash % in Mintty.lnk"
del "%USERPROFILE%\Desktop\WSL Bash ~ in Mintty.lnk"


:explorer context menu

call "%installdir%\remove from context menu.bat"


:undeploy

rem currently not removing software
rem in any case, at least the config file (home\...) should not be removed


:end
