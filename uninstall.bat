@echo off


:undeploy

rem currently not removing software
rem in any case, at least the config file (home\...) should not be removed


:shortcuts

rem delete Desktop Shortcut and Start Menu Shortcut
del "%USERPROFILE%\Desktop\Bash on UoW in Mintty.lnk"
del "%APPDATA%\Microsoft\Windows\Start Menu\Bash on UoW in Mintty.lnk"


:explorer

rem delete Explorer context menu
set userdirname=HKEY_CURRENT_USER\Software\Classes\Directory\shell
set userdirpane=HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell

reg delete "%userdirname%\wsltty" /f
reg delete "%userdirpane%\wsltty" /f


:end
