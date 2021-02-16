#############################################################################
# build a wsltty installer package:
# configure ver=... and minttyver= in this makefile
# make targets:
# make [all]	build a distributable installer (default)
# make pkg	build an installer, bypassing the system checks
# make build	build the software (no installer)
# make install	install wsltty locally from build (no installer needed)
# make wsltty	build the software, using the local copy of mintty


# wsltty release
ver=3.4.5

# wsltty appx release - must have 4 parts!
verx=3.4.5.0


##############################
# mintty release version

minttyver=3.4.5

##############################

# wslbridge2 repository
repo=Biswa96/wslbridge2

# wslbridge2 master release version
wslbridgever=0.6

# wslbridge2 latest version
#archive=master
#wslbridgedir=wslbridge2-$(archive)

# wslbridge2 branch or commit version (from fix-window-resize branch) and dir
#commit=70e0dcea1db122d076ce1578f2a45280cc92d09f
#commit=8b6dd7ee2b3102d72248990c21764c5cf86c6612
#archive=$(commit)
#wslbridgedir=wslbridge2-$(archive)


# wslbridge2 fork repository and version
#repo=mintty/wslbridge2
#wslbridgever=0.5.1


# wslbridge2 release or fork archive and dir
archive=v$(wslbridgever)
wslbridgedir=wslbridge2-$(wslbridgever)


##############################

# mintty branch or commit version
#minttyver=master

# wslbridge branch or commit to build from source;
wslbridge=wslbridge-frontend wslbridge-backend

##############################
# build backend on a musl-libc-based distribution
# (reportedly not needed anymore but untested)
BuildDistr=-d Alpine

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
# clear binaries

clean:
	rm -fr $(wslbridgedir)/bin
	rm -fr bin

#############################################################################
# generation

wslbridge:	$(wslbridge)

$(wslbridgedir).zip:
	$(wgeto) https://github.com/$(repo)/archive/$(archive).zip -o $(wslbridgedir).zip

wslbridge-source:	$(wslbridgedir).zip
	unzip -o $(wslbridgedir).zip
	cp $(wslbridgedir)/LICENSE LICENSE.wslbridge2
	# patch
	cd $(wslbridgedir); patch -p1 < ../0001-notify-size-change-inband.patch

wslbridge-frontend:	wslbridge-source
	echo ------------- Compiling wslbridge2 frontend
	mkdir -p bin
	# frontend build
	cd $(wslbridgedir)/src; make -f Makefile.frontend RELEASE=1
	# extract binaries
	cp $(wslbridgedir)/bin/wslbridge2.exe bin/

windir=$(shell cd "${WINDIR}"; pwd)

wslbridge-backend:	wslbridge-source
	echo ------------- Compiling wslbridge2 backend
	#uname -m | grep x86_64
	mkdir -p bin
	# provide dependencies for backend build
	PATH="$(windir)/Sysnative:${PATH}" cmd /C wsl.exe -u root $(BuildDistr) $(shell env | grep http_proxy=) apk add make g++ linux-headers < /dev/null
	# invoke backend build
	cd $(wslbridgedir)/src; PATH="$(windir)/Sysnative:${PATH}" cmd /C wsl.exe $(BuildDistr) make -f Makefile.backend RELEASE=1 < /dev/null
	# extract binaries
	cp $(wslbridgedir)/bin/wslbridge2-backend bin/

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

CAB=wsltty-$(ver)-$(arch)

copcab:	ver
	mkdir -p $(CAB)
	cp bin/cygwin1.dll $(CAB)/
	cp bin/cygwin-console-helper.exe $(CAB)/
	cp bin/dash.exe $(CAB)/
	cp bin/regtool.exe $(CAB)/
	cp bin/mintty.exe $(CAB)/
	cp bin/zoo.exe $(CAB)/
	cp lang.zoo $(CAB)/
	cp themes.zoo $(CAB)/
	cp sounds.zoo $(CAB)/
	cp charnames.txt $(CAB)/
	cp bin/wslbridge2.exe $(CAB)/
	cp bin/wslbridge2-backend $(CAB)/
	cp mkshortcut.vbs $(CAB)/
	#cp bin/mkshortcut.exe $(CAB)/
	#cp bin/cygpopt-0.dll $(CAB)/
	#cp bin/cygiconv-2.dll $(CAB)/
	#cp bin/cygintl-8.dll $(CAB)/
	cp LICENSE.* $(CAB)/
	cp VERSION $(CAB)/
	cp *.lnk $(CAB)/
	cp *.ico $(CAB)/
	cp *.url $(CAB)/
	cp *.bat $(CAB)/
	cp config-distros.sh $(CAB)/
	cp mkshortcut.vbs $(CAB)/

cop:	copcab
	mkdir -p rel
	cp -fl $(CAB)/* rel/

installer:	cop
	# prepare build of installer
	rm -f rel/$(CAB)-install.exe
	sed -e "s,%version%,$(ver)," -e "s,%arch%,$(arch)," makewinx.cfg > rel/wsltty.SED
	# build installer
	cd rel; iexpress /n wsltty.SED
	# build cab archive
	lcab -r $(CAB) rel/$(CAB).cab

install:	cop installbat

installbat:
	cd rel; cmd /C install

ver:
	echo $(ver) > VERSION

mintty:	mintty-get mintty-build

mintty-usr:	mintty-get mintty-appx

# local wsltty build target:
wsltty:	wslbridge cygwin mintty-build mintty-pkg

# build software without installer:
build:	wslbridge cygwin mintty-get mintty-build mintty-pkg

# standalone wsltty package build target:
pkg:	wslbridge cygwin mintty-get mintty-build mintty-pkg installer

# appx package contents target:
wsltty-appx:	wslbridge appx-bin mintty-get mintty-build-appx mintty-appx

# appx package target:
appx:	wsltty-appx fix-verx
	sh ./build.sh

#############################################################################
# end
