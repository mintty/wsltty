#############################################################################
# build a wsltty installer package:
# configure ver=... and minttyver= in this makefile
# make targets:
# make [all]	build a distributable installer (default)
# make pkg	build an installer, bypassing the system checks
# make wsltty	build the software, using the local copy of mintty


# wsltty release
ver=3.1.0.3

# wsltty appx release - must have 4 parts!
verx=3.1.0.3

# mintty release version
minttyver=3.1.0

# wslbridge2 release version
wslbridgever=0.5

##############################

# mintty branch or commit version
#minttyver=master

# wslbridge branch or commit to build from source;
wslbridge=wslbridge-frontend wslbridge-backend

##############################
# Windows SDK version for appx
WINSDKKEY=/HKEY_LOCAL_MACHINE/SOFTWARE/WOW6432Node/Microsoft/.NET Framework Platform/Setup/Multi-Targeting Pack
WINSDKVER=`regtool list '$(WINSDKKEY)' | sed -e '$$ q' -e d`

#############################################################################
# default target

all:	all-$(notdir $(CURDIR))

all-wsltty:	check pkg

all-wsltty.appx:	appx

#############################################################################
# target checking and some defs

TARGET := $(shell $(CC) -dumpmachine)

ifeq ($(TARGET), i686-pc-cygwin)
  sys := cygwin32
else ifeq ($(TARGET), x86_64-pc-cygwin)
  sys := cygwin64
else ifeq ($(TARGET), i686-pc-msys)
  sys := msys32
else ifeq ($(TARGET), x86_64-pc-msys)
  sys := msys64
else
  $(error Target '$(TARGET)' not supported)
endif

wget=curl -R -L --connect-timeout 55 -O
wgeto=curl -R -L --connect-timeout 55

#############################################################################
# system check:
# - ensure the path name drag-and-drop adaptation works (-> Cygwin, not MSYS)
# - 64 Bit (x86_64) for more stable invocation (avoid fork issues)

arch:=$(shell uname -m)

check:	# checkarch
	echo Building for:
	echo $(arch) | grep .
	# checking suitable host environment; run `make pkg` to bypass
	# check cygwin (vs msys) for proper drag-and-drop paths:
	uname | grep CYGWIN

checkarch:
	# check 32 bit to ensure 32-Bit Windows support, just in case:
	#uname -m | grep i686
	# check 64 bit to provide 64-Bit stability support:
	#uname -m | grep x86_64

#############################################################################
# patch version information for appx package configuration

fix-verx:
	echo patching $(WINSDKVER) into Launcher config
	cd Launcher; sed -i~ -e "/<supportedRuntime / s,Version=v[.0-9]*,Version=$(WINSDKVER)," app.config
	echo patched app.config
	cd Launcher; sed -i~ -e "/<TargetFrameworkVersion>/ s,v[.0-9]*,$(WINSDKVER)," Launcher.csproj
	echo patched Launcher.csproj
	echo patching $(verx) into app config
	sed -i~ -e '/<Identity / s,Version="[.0-9]*",Version="$(verx)",' AppxManifest.xml
	echo patched AppxManifest.xml

#############################################################################
# generation

wslbridge:	$(wslbridge)

wslbridge2-$(wslbridgever).zip:
	$(wgeto) https://github.com/Biswa96/wslbridge2/archive/v$(wslbridgever).zip -o wslbridge2-$(wslbridgever).zip

wslbridge-source:	wslbridge2-$(wslbridgever).zip
	unzip -ou wslbridge2-$(wslbridgever).zip
	cp wslbridge2-$(wslbridgever)/LICENSE LICENSE.wslbridge2

wslbridge-frontend:	wslbridge-source
	echo ------------- Compiling wslbridge2 frontend
	mkdir -p bin
	# frontend build
	cd wslbridge2-$(wslbridgever)/src; make -f Makefile.frontend RELEASE=1
	# extract binaries
	cp wslbridge2-$(wslbridgever)/bin/wslbridge2.exe bin/

# build backend on a musl-libc-based distribution
BuildDistr=Alpine

windir=$(shell cd "${WINDIR}"; pwd)

wslbridge-backend:	wslbridge-source
	echo ------------- Compiling wslbridge2 backend
	#uname -m | grep x86_64
	mkdir -p bin
	# provide dependencies for backend build
	PATH="$(windir)/Sysnative:${PATH}" cmd /C wsl.exe -u root -d $(BuildDistr) $(shell env | grep http_proxy=) apk add make g++ linux-headers < /dev/null
	# invoke backend build
	cd wslbridge2-$(wslbridgever)/src; PATH="$(windir)/Sysnative:${PATH}" cmd /C wsl.exe -d $(BuildDistr) make -f Makefile.backend RELEASE=1 < /dev/null
	# extract binaries
	cp wslbridge2-$(wslbridgever)/bin/wslbridge2-backend bin/

mintty-get:
	$(wgeto) https://github.com/mintty/mintty/archive/$(minttyver).zip -o mintty-$(minttyver).zip
	unzip -o mintty-$(minttyver).zip
	cp mintty-$(minttyver)/icon/terminal.ico mintty.ico

wslbuild=LDFLAGS="-static -static-libgcc -s"
appxbuild=$(wslbuild) CCOPT=-DWSLTTY_APPX
wslversion=VERSION_SUFFIX="– wsltty $(ver)" WSLTTY_VERSION="$(ver)"
appxversion=VERSION_SUFFIX="– wsltty appx $(verx)" WSLTTY_VERSION="$(verx)"

mintty-build:
	# ensure rebuild of version-specific check and message
	rm -f mintty-$(minttyver)/bin/*/windialog.o
	# build mintty
	cd mintty-$(minttyver)/src; make $(wslbuild) $(wslversion)
	mkdir -p bin
	cp mintty-$(minttyver)/bin/mintty.exe bin/
	strip bin/mintty.exe

mintty-build-appx:
	# ensure rebuild of version-specific check and message
	rm -f mintty-$(minttyver)/bin/*/windialog.o
	# build mintty
	cd mintty-$(minttyver)/src; make $(appxbuild) $(appxversion)
	mkdir -p bin
	cp mintty-$(minttyver)/bin/mintty.exe bin/
	strip bin/mintty.exe

mintty-pkg:
	cp mintty-$(minttyver)/LICENSE LICENSE.mintty
	cd mintty-$(minttyver)/lang; zoo a lang *.po; mv lang.zoo ../../
	cd mintty-$(minttyver)/themes; zoo a themes *[!~]; mv themes.zoo ../../
	cd mintty-$(minttyver)/sounds; zoo a sounds *.wav *.WAV *.md; mv sounds.zoo ../../
	# add charnames.txt to support "Character Info"
	cd mintty-$(minttyver)/src; sh ./mknames
	cp mintty-$(minttyver)/src/charnames.txt .

mintty-appx:
	mkdir -p usr/share/mintty
	cd usr/share/mintty; mkdir -p lang themes sounds info
	cp mintty-$(minttyver)/lang/*.po usr/share/mintty/lang/
	cp mintty-$(minttyver)/themes/*[!~] usr/share/mintty/themes/
	cp mintty-$(minttyver)/sounds/*.wav usr/share/mintty/sounds/
	cp mintty-$(minttyver)/sounds/*.WAV usr/share/mintty/sounds/
	# add charnames.txt to support "Character Info"
	cd mintty-$(minttyver)/src; sh ./mknames
	cp mintty-$(minttyver)/src/charnames.txt usr/share/mintty/info/

cygwin:	# mkshortcutexe
	mkdir -p bin
	cp /bin/cygwin1.dll bin/
	cp /bin/cygwin-console-helper.exe bin/
	cp /bin/dash.exe bin/
	cp /bin/regtool.exe bin/
	cp /bin/zoo.exe bin/

mkshortcutexe:	bin/mkshortcut.exe

bin/mkshortcut.exe:	mkshortcut.c
	echo mksh
	gcc -o bin/mkshortcut mkshortcut.c -lpopt -lole32 /usr/lib/w32api/libuuid.a
	cp /bin/cygpopt-0.dll bin/
	cp /bin/cygiconv-2.dll bin/
	cp /bin/cygintl-8.dll bin/

appx-bin:
	mkdir -p bin
	cp /bin/cygwin1.dll bin/
	cp /bin/cygwin-console-helper.exe bin/

cop:	ver
	mkdir -p rel
	rm -f rel/wsltty-$(ver)-install-$(arch).exe
	sed -e "s,%version%,$(ver)," -e "s,%arch%,$(arch)," makewinx.cfg > rel/wsltty.SED
	cp bin/cygwin1.dll rel/
	cp bin/cygwin-console-helper.exe rel/
	cp bin/dash.exe rel/
	cp bin/regtool.exe rel/
	cp bin/mintty.exe rel/
	cp bin/zoo.exe rel/
	cp lang.zoo rel/
	cp themes.zoo rel/
	cp sounds.zoo rel/
	cp charnames.txt rel/
	cp bin/wslbridge2.exe rel/
	cp bin/wslbridge2-backend rel/
	cp mkshortcut.vbs rel/
	#cp bin/mkshortcut.exe rel/
	#cp bin/cygpopt-0.dll rel/
	#cp bin/cygiconv-2.dll rel/
	#cp bin/cygintl-8.dll rel/
	cp LICENSE.* rel/
	cp VERSION rel/
	cp *.lnk rel/
	cp *.ico rel/
	cp *.url rel/
	cp *.bat rel/
	cp *.sh rel/
	cp *.vbs rel/

cab:	cop
	cd rel; iexpress /n wsltty.SED

install:	cop installbat

installbat:
	cd rel; cmd /C install

ver:
	echo $(ver) > VERSION

mintty:	mintty-get mintty-build

mintty-usr:	mintty-get mintty-appx

# local wsltty build target:
wsltty:	wslbridge cygwin mintty-build mintty-pkg

# standalone wsltty package build target:
pkg:	wslbridge cygwin mintty-get mintty-build mintty-pkg cab

# appx package contents target:
wsltty-appx:	wslbridge appx-bin mintty-get mintty-build-appx mintty-appx

# appx package target:
appx:	wsltty-appx fix-verx
	sh ./build.sh

#############################################################################
# end
