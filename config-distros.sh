#! /bin/sh

contextmenu=false
remove=false
case "$1" in
-contextmenu)	contextmenu=true
		shift;;
-contextmenu-remove)
		contextmenu=true
		remove=true
		shift;;
-shortcuts-remove)
		remove=true
		shift;;
esac

# test w/o WSL: call this script with REGTOOLFAKE=true dash config-distros.sh
if ${REGTOOLFAKE:-false}
then
regtool () {
	case "$1" in
	-*)	shift;;
	esac
	key=`echo $2 | sed -e 's,.*{\(.*\)}.*,\1,' -e t -e d`
	case "$1.$2" in
	list.*)				if $contextmenu
					then	echo "{0}"
					else	echo "{1}"; echo "{2}"
					fi;;
	get.*/DistributionName)		echo "distro$key";;
	get.*/BasePath)			echo "C:\\Program\\{$key}\\State";;
	get.*/PackageFamilyName)	echo "distro{$key}";;
	get.*/PackageFullName)		echo "C:\\Program\\{$key}";;
	esac
}
fi

# dash built-in echo enforces interpretation of \t etc
echoc () {
	cmd /c echo $*
}

while read line; do echo "$line"; done <</EOB > mkbat.bat
@echo off
echo Creating %1.bat

echo @echo off> %1.bat
echo rem Start mintty terminal for WSL package %distro% in current directory>> %1.bat
echo %target% -i "%icon%" %minttyargs% %bridgeargs%>> %1.bat

echo Created %1.bat
/EOB

PATH=/bin:$PATH

lxss="/HKEY_CURRENT_USER/Software/Microsoft/Windows/CurrentVersion/Lxss"
schema="/HKEY_CURRENT_USER/Software/Classes/Local Settings/Software/Microsoft/Windows/CurrentVersion/AppModel/SystemAppData"

(regtool list "$lxss" 2>/dev/null || echo "No WSL packages registered" >&2) |
while read guid
do
  case $guid in
  {*)
	distro=`regtool get "$lxss/$guid/DistributionName"`
	case "$distro" in
	Legacy)	name="Bash on Windows"
		launch=
		launcher="$SYSTEMROOT/System32/bash.exe"
		;;
	*)	name="$distro"
		launch="$distro"
		launcher="$LOCALAPPDATA/Microsoft/WindowsApps/$distro.exe"
		;;
	esac
	basepath=`regtool get "$lxss/$guid/BasePath"`
	if package=`regtool -q get "$lxss/$guid/PackageFamilyName"`
	then	instdir=`regtool get "$schema/$package/Schemas/PackageFullName"`
		if [ -r "$PROGRAMFILES/WindowsApps/$instdir/images/icon.ico" ]
		then	icon="%PROGRAMFILES%/WindowsApps/$instdir/images/icon.ico"
		else	icon="%LOCALAPPDATA%/wsltty/wsl.ico"
		fi
		root="$basepath/rootfs"
	else	icon="%LOCALAPPDATA%/lxss/bash.ico"
		root="$basepath"
	fi
	echoc "distro $distro"
	echoc "- guid $guid"
	echoc "- (launcher $launcher)"
	echoc "- icon $icon"
	echoc "- root $root"

	target='%LOCALAPPDATA%\wsltty\bin\mintty.exe'
	minttyargs='--wsl --rootfs="'"$root"'" -h err --configdir="%APPDATA%\wsltty" -o Locale=C -o Charset=UTF-8 /bin/wslbridge '
	#if [ -z "$launch" ]
	#then	bridgeargs='-t /bin/bash'
	#else	bridgeargs='-l "'"$launch"'" -t /bin/bash'
	#fi
	bridgeargs='--distro-guid "'"$guid"'" -t /bin/bash'

	export target minttyargs bridgeargs icon
	export distro

    if $contextmenu
    then
      # create context menu entry
      #cmd /C mkcontext "$name"
      direckey='HKEY_CURRENT_USER\Software\Classes\Directory'
      if $remove
      then
	reg delete "$direckey\\shell\\$name" /f
	reg delete "$direckey\\Background\\shell\\$name" /f
      else
	reg add "$direckey\\shell\\$name" /d "$name in Mintty Here" /f
	reg add "$direckey\\shell\\$name" /v Icon /d "$icon" /f
	cmd /C reg add "$direckey\\shell\\$name\\command" /d "\"$target\" -i \"$icon\" --dir \"%1\" $minttyargs $brigdeargs" /f
	reg add "$direckey\\Background\\shell\\$name" /d "$name in Mintty Here" /f
	reg add "$direckey\\Background\\shell\\$name" /v Icon /d "$icon" /f
	cmd /C reg add "$direckey\\Background\\shell\\$name\\command" /d "\"$target\" -i \"$icon\" $minttyargs $brigdeargs" /f
      fi
    else

      if $remove
      then
	cmd /C del "%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\$name ~ in Mintty.lnk"
	cmd /C del "%LOCALAPPDATA%\\Microsoft\\WindowsApps\\$name.bat"
	cmd /C del "%LOCALAPPDATA%\\Microsoft\\WindowsApps\\$name~.bat"
      else
	# create desktop/start menu shortcut
	cscript /nologo mkshortcut.vbs "/name:$name in Mintty"
	# copy to Start Menu WSLtty subfolder
	rem cmd /C mkdir "%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\WSLtty\\WinUser"
	cmd /C copy "$name in Mintty.lnk" "%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\WSLtty"

	# create command-line launch script
	cmd /C mkbat.bat "$name"
	#cmd /C mkbat.bat "$name in Mintty"
	# copy to WSLtty home and to WindowsApps launch folder
	cmd /C copy "$name.bat" "%LOCALAPPDATA%\\wsltty\\$name.bat"
	cmd /C copy "$name.bat" "%LOCALAPPDATA%\\Microsoft\\WindowsApps\\$name.bat"

	# prepare versions to target WSL home directory
	bridgeargs="-C~ $bridgeargs"

	# create optional addition desktop shortcut
	cscript /nologo mkshortcut.vbs "/name:$name ~ in Mintty"
	# copy to Start Menu
	cmd /C copy "$name ~ in Mintty.lnk" "%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs"

	# create command-line launch script
	cmd /C mkbat.bat "$name~"
	#cmd /C mkbat.bat "$name~ in Mintty"
	# copy to WSLtty home and to WindowsApps launch folder
	cmd /C copy "$name~.bat" "%LOCALAPPDATA%\\wsltty\\$name~.bat"
	cmd /C copy "$name~.bat" "%LOCALAPPDATA%\\Microsoft\\WindowsApps\\$name~.bat"
      fi

    fi;;
  esac
done
