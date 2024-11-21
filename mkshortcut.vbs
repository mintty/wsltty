rem cscript mkshortcut.vbs [/param:arg] /target:link

rem /target:%LOCALAPPDATA%\wsltty\bin\mintty.exe
rem /wdir:%USERPROFILE%
rem /icon:%LOCALAPPDATA%\wsltty\wsl.ico
rem deprecated: /icon:%LOCALAPPDATA%\lxss\bash.ico
rem deprecated: %
rem /arguments:--wsl -o Locale=C -o Charset=UTF-8 /bin/wslbridge -t /bin/bash
rem deprecated: ~
rem /arguments:--wsl -o Locale=C -o Charset=UTF-8 /bin/wslbridge -C~ -t /bin/bash
rem deprecated: -l
rem /arguments:--wsl -o Locale=C -o Charset=UTF-8 /bin/wslbridge -t /bin/bash -l

rem General - Name:
name = Wscript.Arguments.Named("name") & ".lnk"
set wshell = WScript.CreateObject("WScript.Shell")
wscript.echo "Creating " & name
set lnk = wshell.CreateShortcut(name)

rem Target:
rem lnk.TargetPath = Wscript.Arguments.Named("target")
rem lnk.Arguments = Wscript.Arguments.Named("arguments")

lnk.TargetPath = wshell.ExpandEnvironmentStrings("%target%")
minttyargs = wshell.ExpandEnvironmentStrings("%minttyargs%")
bridgeargs = wshell.ExpandEnvironmentStrings("%bridgeargs%")
lnk.Arguments = minttyargs & " " & bridgeargs
rem wscript.echo "minttyargs: " & minttyargs
rem wscript.echo lnk.Arguments

rem Start in:
rem Working directory; Arguments.Named would take "/wdir:C:\..." parameters
rem wdir = Wscript.Arguments.Named("wdir")
rem Working directory; function ExpandEnvironmentStrings cannot pass empty
wdir = wshell.ExpandEnvironmentStrings("%wdir%")
if IsEmpty(wdir) then
  lnk.WorkingDirectory = "%USERPROFILE%"
elseif wdir = "." then
  lnk.WorkingDirectory = ""
else
  lnk.WorkingDirectory = wdir
end if

rem Icon:
rem icon = Wscript.Arguments.Named("icon")
rem rem iconoffset = Wscript.Arguments.Named("iconoffset")
rem rem icon = icon & ", " & iconoffset
icon = wshell.ExpandEnvironmentStrings("%icon%")
rem wscript.echo "icon: " & icon
lnk.IconLocation = icon
rem rem lnk.IconLocation = "%LOCALAPPDATA%\lxss\bash.ico"
rem lnk.IconLocation = "%LOCALAPPDATA%\wsltty\wsl.ico"

rem Shorcut key:
rem lnk.HotKey = "ALT+CTRL+W"

rem Run:
rem 1: Normal 7: Minimized 3: Maximized
rem lnk.WindowStyle = 1
min = Wscript.Arguments.Named("min")
if min then
  lnk.WindowStyle = 7
end if

rem Comment:
rem lnk.IconLocation = Wscript.Arguments.Named("desc")
rem lnk.Description = "WSLtty"

lnk.Save
wscript.echo "Created " & name
wscript.echo
