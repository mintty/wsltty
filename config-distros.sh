#! /bin/sh

# dash built-in echo enforces interpretation of \t etc
echoc () {
  #cmd /c echo $*
  printf '%s\n' "$*"
}

copy () {
  from="$1"
  to="$2"
  export from to
  cmd /c cmd2.bat copy
}

delete () {
  from="$1"
  to="$1"	# same again, to fill parameter
  export from to
  cmd /c cmd2.bat del/F
}

compare () {
  from="$1"
  to="$2"
  export from to
  cmd /c cmd2.bat comp/M
}


case "$installdir" in
?*)	custominst=true;;
"")	custominst=false;;
esac

INSTDIR="${installdir:-$LOCALAPPDATA/wsltty}"
echoc "Installing wsltty into $INSTDIR"
INSTDIR=`cd "$INSTDIR"; pwd`
installcop=${installdir:-"$LOCALAPPDATA\\wsltty"}
installdir=${installdir:-'%LOCALAPPDATA%\wsltty'}

target="$installdir"'\bin\mintty.exe'
case "$INSTDIR" in
*/)	TARGETPATH="$INSTDIR"bin/mintty.exe;;
*)	TARGETPATH="$INSTDIR"/bin/mintty.exe;;
esac

CONFDIR="${configdir:-$APPDATA/wsltty}"
configdir=${configdir:-'%APPDATA%\wsltty'}

PATH=/bin:"$PATH":$SYSTEMROOT/System32

contextmenu=false
remove=false
alldistros=true
config=true

case "/$0" in
*/wsl*)
  config=false;;
esac

case "$1" in
-info)
  config=false
  shift;;
-shortcuts)
  shift;;
-shortcuts-remove)
  remove=true
  shift;;
-default)
  alldistros=false
  shift;;
-contextmenu)
  contextmenu=true
  shift;;
-contextmenu-default)
  contextmenu=true
  alldistros=false
  shift;;
-contextmenu-remove)
  contextmenu=true
  remove=true
  direckey='/HKEY_CURRENT_USER/Software/Classes/Directory'

  regtool list "$direckey/shell" 2>/dev/null |
  while read name
  do
    case `regtool get "$direckey/shell/$name/command/"` in
    *bin\\mintty.exe*/bin/wslbridge*|*bin\\mintty.exe*--WSL*)
      regtool remove "$direckey/shell/$name/command"
      regtool remove "$direckey/shell/$name"
      ;;
    esac
  done

  regtool list "$direckey/Background/shell" 2>/dev/null |
  while read name
  do
    case `regtool get "$direckey/Background/shell/$name/command/"` in
    *bin\\mintty.exe*/bin/wslbridge*|*bin\\mintty.exe*--WSL*)
      regtool remove "$direckey/Background/shell/$name/command"
      regtool remove "$direckey/Background/shell/$name"
      ;;
    esac
  done
  exit
  shift;;
esac


if $config && ! $contextmenu
then
  # remove shortcut entries in Start menu and cmd-line bat shortcuts
  (cd "$INSTDIR"
   for lnk in *.lnk
   do
     if compare "$lnk" "$APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\$lnk"
     then delete "$APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\$lnk"
     fi
   done
   for bat in *.bat
   do
     if compare "$bat" "$LOCALAPPDATA\\Microsoft\\WindowsApps\\$bat"
     then delete "$LOCALAPPDATA\\Microsoft\\WindowsApps\\$bat"
     fi
   done
  )
fi

# test w/o WSL: call this script with REGTOOLFAKE=true dash config-distros.sh
if ${REGTOOLFAKE:-false}
then
regtool () {
  case "$1" in
  -*)  shift;;
  esac
  key=`echo $2 | sed -e 's,.*{\(.*\)}.*,\1,' -e t -e d`
  case "$1.$2" in
  list.*)
        if $contextmenu
        then  echo "{0}"
        else  echo "{1}"; echo "{2}"
        fi;;
  get.*/DistributionName)
        echo "distro$key";;
  get.*/BasePath)
        echo "C:\\Program\\{$key}\\State";;
  get.*/PackageFamilyName)
        echo "distro{$key}";;
  get.*/PackageFullName)
        echo "C:\\Program\\{$key}";;
  esac
}
fi


if $config
then while read line; do echo "$line"; done <</EOB > mkbat.bat
@echo off
echo Creating %1.bat

echo @echo off> %1.bat
echo rem Start mintty terminal for WSL package %name% in current directory>> %1.bat
echo %target% -i "%icon%" %minttyargs% %bridgeargs% %%*>> %1.bat
/EOB
fi

if $custominst && $config && ! $remove
then
  #mkshortcut.exe -n "add to context menu" -a "$installdir/config-distros.sh -contextmenu" "$installdir/bin/dash.exe" -i '%SystemRoot%\System32\filemgmt.dll' -s min -d "" -w "$installdir"
  #mkshortcut.exe -n "add default to context menu" -a "$installdir/config-distros.sh -contextmenu-default" "$installdir/bin/dash.exe" -i '%SystemRoot%\System32\filemgmt.dll' -s min -d "" -w "$installdir"
  #mkshortcut.exe -n "remove from context menu" -a "$installdir/config-distros.sh -contextmenu-remove" "$installdir/bin/dash.exe" -i '%SystemRoot%\System32\filemgmt.dll' -s min -d "" -w "$installdir"
  #mkshortcut.exe -n "configure WSL shortcuts" -a "$installdir/config-distros.sh" "$installdir/bin/dash.exe" -i '%SystemRoot%\System32\filemgmt.dll' -s min -d "" -w "$installdir"

  icon='%SystemRoot%\System32\filemgmt.dll'
  wdir="$installdir"
  target="$installdir/bin/dash.exe"
  minttyargs="/config-distros.sh"
  bridgeargs=
  export icon wdir target minttyargs bridgeargs
  cscript /nologo mkshortcut.vbs "/name:configure WSL shortcuts" "/min:true"
  bridgeargs=-contextmenu
  cscript /nologo mkshortcut.vbs "/name:add to context menu" "/min:true"
  bridgeargs=-contextmenu-default
  cscript /nologo mkshortcut.vbs "/name:add default to context menu" "/min:true"
  bridgeargs=-contextmenu-remove
  cscript /nologo mkshortcut.vbs "/name:remove from context menu" "/min:true"

  copy "add to context menu.lnk" "$APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\WSLtty"
  copy "add default to context menu.lnk" "$APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\WSLtty"
  copy "remove from context menu.lnk" "$APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\WSLtty"
  copy "configure WSL shortcuts.lnk" "$APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\WSLtty"

  # restore target
  target="$installdir"'\bin\mintty.exe'
fi

lxss="/HKEY_CURRENT_USER/Software/Microsoft/Windows/CurrentVersion/Lxss"
schema="/HKEY_CURRENT_USER/Software/Classes/Local Settings/Software/Microsoft/Windows/CurrentVersion/AppModel/SystemAppData"

appex () {
  while read line
  do
	case "$line" in
	*Application*Executable*)
		for item in $line
		do	case "$item" in
			Executable=*)
				eval $item
				echo "$Executable"
				break;;
			esac
		done
		break;;
	esac
  done < $*
}

config () {
  guid="$1"
  ok=false
  case $guid in
  {*)
    distro=`regtool get "$lxss/$guid/DistributionName"`
    case "$distro" in
    Legacy)
    	name="Bash on Windows"
    	launcher="$SYSTEMROOT/System32/bash.exe"
    	;;
    *)	name="$distro"
    	launcher="$LOCALAPPDATA/Microsoft/WindowsApps/$distro.exe"
    	;;
    esac
    basepath=`regtool get "$lxss/$guid/BasePath"`
    if package=`regtool -q get "$lxss/$guid/PackageFamilyName"`
    then
    	distrinst=`regtool get "$schema/$package/Schemas/PackageFullName"`
    	# get actual executable path (may not match $distro) from app manifest
    	manifest="$ProgramW6432/WindowsApps/$distrinst/AppxManifest.xml"
    	psh_cmd='([xml]$(Get-Content '"\"$manifest\""')).Package.Applications.Application.Executable'
    	executable=`appex "$manifest"`
    	if [ -r "$ProgramW6432/WindowsApps/$distrinst/$executable" ]
    	then	icon="$ProgramW6432/WindowsApps/$distrinst/$executable"
    	elif [ -r "$ProgramW6432/WindowsApps/$distrinst/images/icon.ico" ]
    	then	icon="$ProgramW6432/WindowsApps/$distrinst/images/icon.ico"
    	else	icon="$installcop"'\wsl.ico'
    	fi
    	root="$basepath/rootfs"
    elif [ -f "$basepath/$distro.exe" ]
    then
    	icon="$basepath/$distro.exe"
    	root="$basepath/rootfs"
    elif [ -d "$LOCALAPPDATA/lxss" ]
    then
    	# legacy "Bash on Windows"
    	icon="$LOCALAPPDATA/lxss/bash.ico"
    	root="$basepath"
    else
    	# imported distro? (#226, #236)
    	icon="$installcop"'\wsl.ico'
    	root="$basepath/rootfs"
    fi

    # invocation parameters for mintty
    minttyargs='--WSL="'"$distro"'" --configdir="'"$configdir"'"'
    # MINTARGS deprecated; used for mkshortcut.exe rather than mkshortcut.vbs
    MINTARGS='--WSL="'"$distro"'" --configdir="'"$CONFDIR"'"'
    # invocation commands (deprecated for mintty, used for start menu scripts)
    #bridgeargs='--distro-guid "'"$guid"'" -t'

    ok=true;;
  DefaultDistribution|"")	# WSL default installation
    distro=
    name=WSL
    icon="$installcop"'\wsl.ico'
    minttyargs='--WSL= --configdir="'"$configdir"'"'
    MINTARGS='--WSL= --configdir="'"$CONFDIR"'"'
    #bridgeargs='-t'

    ok=true;;
  esac
  bridgeargs=" -"	# now used to request login mode

  echoc "distro '$distro'"
  echoc "- name '$name'"
  echoc "- guid $guid"
  echoc "- (launcher $launcher)"
  echoc "- icon $icon"
  echoc "- root $root"
  wdir=%USERPROFILE%

  if $ok && ! $remove && [ -n "$distro" ]
  then	# fix #163: backend missing +x with certain mount options
	echo Setting +x wslbridge2 backends for distro "'$distro'"
	(cd "$INSTDIR"; cd bin; PATH="${WINDIR}/Sysnative:${PATH}" wsl.exe -d "$distro" chmod +x wslbridge2-backend)
#	(cd "$LOCALAPPDATA/wsltty/bin"; wsl.exe -d "$distro" chmod +x wslbridge2-backend)
#	(cd ... ; "$SYSTEMROOT/System32/bash.exe" "$guid" -c chmod +x wslbridge2-backend)
  fi

  if $ok && $config
  then
    export wdir name target minttyargs bridgeargs icon

    if $contextmenu
    then
      # context menu entries
      direckey='HKEY_CURRENT_USER\Software\Classes\Directory'
      keyname="${name}_Terminal"
      if $remove
      then
        # obsolete; handled above
        reg delete "$direckey\\shell\\$keyname" /f
        reg delete "$direckey\\Background\\shell\\$keyname" /f
      else
        direckey='/HKEY_CURRENT_USER/Software/Classes/Directory'
        echoc Registry setting "$direckey/[Background/]shell/$keyname"
        target="$installcop"'\bin\mintty.exe'

        regtool add "$direckey/shell"
        regtool add "$direckey/shell/$keyname"
        regtool set "$direckey/shell/$keyname/" -s "$name Terminal"
        regtool set "$direckey/shell/$keyname/Icon" -s "$icon"
        regtool add "$direckey/shell/$keyname/command"
        regtool set "$direckey/shell/$keyname/command/" -s "\"$target\" -i \"$icon\" --dir \"%1\" $MINTARGS $bridgeargs"

        regtool add "$direckey/Background/shell"
        regtool add "$direckey/Background/shell/$keyname"
        regtool set "$direckey/Background/shell/$keyname/" -s "$name Terminal"
        regtool set "$direckey/Background/shell/$keyname/Icon" -s "$icon"
        regtool add "$direckey/Background/shell/$keyname/command"
        regtool set "$direckey/Background/shell/$keyname/command/" -s "\"$target\" -i \"$icon\" $MINTARGS $bridgeargs"
      fi
    else
      # invocation shortcuts and scripts
      if $remove
      then
        delete "$APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\$name Terminal.lnk"
        delete "$LOCALAPPDATA\\Microsoft\\WindowsApps\\$name.bat"
        delete "$LOCALAPPDATA\\Microsoft\\WindowsApps\\$name~.bat"

        if [ "$name" = "WSL" ]
        then
              # determine actual Desktop folder
              desktopkey='\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\Desktop'
              desktop=`regtool get "$desktopkey"`
              case "$desktop" in
              %USERPROFILE%*)	desktop="$USERPROFILE${desktop#%USERPROFILE%}";;
              esac
              delete "$desktop\\$name Terminal.lnk"
        fi
      else
        # desktop shortcut in %USERPROFILE% -> Start Menu - WSLtty
        cscript /nologo mkshortcut.vbs "/name:$name Terminal %"
        #mkshortcut.exe -n "$name Terminal %" -i "$icon" "$TARGETPATH" -a "$MINTARGS" -d "" -w %USERPROFILE%
        copy "$name Terminal %.lnk" "$APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\WSLtty"

        # launch script in . -> WSLtty home, WindowsApps launch folder
        cmd /C mkbat.bat "$name"
        copy "$name.bat" "$LOCALAPPDATA\\Microsoft\\WindowsApps"

        # store backup copies in installation dir
        if [ "$PWD" != "$INSTDIR" ]
        then
              copy "$name Terminal %.lnk" "$installcop"
              copy "$name.bat" "$installcop"
        fi

        # prepare versions to target WSL home directory
        #bridgeargs="-C~ $bridgeargs"
        minttyargs="$minttyargs -~"
        MINTARGS="$MINTARGS -~"

        # desktop shortcut in ~ -> Start Menu
        cscript /nologo mkshortcut.vbs "/name:$name Terminal"
        #mkshortcut.exe -n "$name Terminal" -i "$icon" "$TARGETPATH" -a "$MINTARGS" -d "" -w %USERPROFILE%
        copy "$name Terminal.lnk" "$APPDATA\\Microsoft\\Windows\\Start Menu\\Programs"

        # default desktop shortcut in ~ -> Desktop
        if [ "$name" = "WSL" ]
        then
              #copy "$name Terminal.lnk" "$USERPROFILE\\Desktop"
              #copy "$name Terminal.lnk" "$APPDATA\\..\\Desktop\\"
              # the above does not work reliably (see #166)
              # determine actual Desktop folder
              desktopkey='\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\Desktop'
              desktop=`regtool get "$desktopkey"`
              case "$desktop" in
              %USERPROFILE%*)	desktop="$USERPROFILE${desktop#%USERPROFILE%}";;
              esac
              copy "$name Terminal.lnk" "$desktop\\"
        fi

        # launch script in ~ -> WSLtty home, WindowsApps launch folder
        cmd /C mkbat.bat "$name~"
        copy "$name~.bat" "$LOCALAPPDATA\\Microsoft\\WindowsApps"

        # store backup copies in installation dir
        if [ "$PWD" != "$INSTDIR" ]
        then
              copy "$name Terminal.lnk" "$installcop"
              copy "$name~.bat" "$installcop"
        fi
      fi

    fi
  fi
}

# ensure proper parameter passing to cmd /C
chcp.com 65001 # just in case; seems to work without as well

# configure for all distros, plus default distro
for guid in `
  if $alldistros
  then  regtool list "$lxss" 2>/dev/null
  else  echo DefaultDistribution
  fi || echo "No WSL packages registered" >&2
`
do	config $guid
done

