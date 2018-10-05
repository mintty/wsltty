#############################################################################
# build a wsltty installer package:
# configure ver=... and minttyver= in this makefile
# make targets:
# make [all]	build a distributable installer (default)
# make pkg	build an installer, bypassing the system checks
# make wsltty	build the software, using the local copy of mintty


# wsltty release
ver=1.9.3

# wsltty appx release
verx=0.9.3

##############################
# mintty release version
minttyver=2.9.3

# or mintty branch or commit version
#minttyver=master

##############################
# wslbridge binary package; may be overridden below
wslbridge=wslbridge-package
wslbridgever=0.2.4

# or wslbridge branch or commit to build from source;
# also set wslbridge-commit
wslbridge=wslbridge-frontend wslbridge-backend

# release 0.2.0 does not have cygwin_internal(CW_SYNC_WINENV) yet:
#wslbridge-commit=master

# use --distro-guid option (merged into 0.2.4):
#wslbridge-commit=cb22e3f6f989cefe5b6599d3c04422ded74db664

# after 0.2.4, from branch login-mode:
wslbridge-commit=04a060505860915c99bc336dbeb80269771a80b7

# after 0.2.4, from branch wslpath:
wslbridge-commit=29df86d87135caec8424c08f031ce121a3a39ae1

# after 0.2.4, merged wslpath branch:
wslbridge-commit=06fb7acba28d7f37611f3911685af214739895a0

# after 0.2.4, with --backend option:
wslbridge-commit=47b41bec6c32da58ab01de9345087b1a4fd836e3

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

check:
	# checking suitable host environment; run `make pkg` to bypass
	# check cygwin (vs msys) for proper drag-and-drop paths:
	uname | grep CYGWIN
	# check 32 bit to ensure 32-Bit Windows support, just in case:
	#uname -m | grep i686
	# check 64 bit to provide 64-Bit stability support:
	uname -m | grep x86_64

#############################################################################
# generation

wslbridge:	$(wslbridge)

wslbridge-package:
	$(wget) https://github.com/rprichard/wslbridge/releases/download/$(wslbridgever)/wslbridge-$(wslbridgever)-$(sys).tar.gz
	tar xvzf wslbridge-$(wslbridgever)-$(sys).tar.gz
	mkdir -p bin
	cp wslbridge-$(wslbridgever)-$(sys)/wslbridge* bin/
	tr -d '\015' < wslbridge-$(wslbridgever)-$(sys)/LICENSE.txt > LICENSE.wslbridge

wslbridge-source:	wslbridge-$(wslbridge-commit).zip
	unzip -o wslbridge-$(wslbridge-commit).zip
	tr -d '\015' < wslbridge-$(wslbridge-commit)/LICENSE.txt > LICENSE.wslbridge

wslbridge-$(wslbridge-commit).zip:
	$(wgeto) https://github.com/rprichard/wslbridge/archive/$(wslbridge-commit).zip -o wslbridge-$(wslbridge-commit).zip

wslbridge-frontend:	wslbridge-source
	cd wslbridge-$(wslbridge-commit)/frontend; make
	strip wslbridge-$(wslbridge-commit)/out/wslbridge.exe
	mkdir -p bin
	cp wslbridge-$(wslbridge-commit)/out/wslbridge.exe bin/

wslbridge-backend:	wslbridge-source
	cd wslbridge-$(wslbridge-commit)/backend; if uname -m | grep x86_64; then cmd /C wsl make; else wslbridge make; fi
	mkdir -p bin
	cp wslbridge-$(wslbridge-commit)/out/wslbridge-backend bin/

mintty-get:
	$(wgeto) https://github.com/mintty/mintty/archive/$(minttyver).zip -o mintty-$(minttyver).zip
	unzip -o mintty-$(minttyver).zip

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

mintty-build-appx:
	# ensure rebuild of version-specific check and message
	rm -f mintty-$(minttyver)/bin/*/windialog.o
	# build mintty
	cd mintty-$(minttyver)/src; make $(appxbuild) $(appxversion)
	mkdir -p bin
	cp mintty-$(minttyver)/bin/mintty.exe bin/

mintty-pkg:
	cp mintty-$(minttyver)/LICENSE LICENSE.mintty
	cd mintty-$(minttyver)/lang; zoo a lang *.po; mv lang.zoo ../../
	cd mintty-$(minttyver)/themes; zoo a themes *[!~]; mv themes.zoo ../../
	# add charnames.txt to support "Character Info"
	cd mintty-$(minttyver)/src; sh ./mknames
	cp mintty-$(minttyver)/src/charnames.txt .

mintty-appx:
	mkdir -p usr/share/mintty
	cd usr/share/mintty; mkdir -p lang themes info
	cp mintty-$(minttyver)/lang/*.po usr/share/mintty/lang/
	cp mintty-$(minttyver)/themes/*[!~] usr/share/mintty/themes/
	# add charnames.txt to support "Character Info"
	cd mintty-$(minttyver)/src; sh ./mknames
	cp mintty-$(minttyver)/src/charnames.txt usr/share/mintty/info/

cygwin:
	mkdir -p bin
	cp /bin/cygwin1.dll bin/
	cp /bin/cygwin-console-helper.exe bin/
	cp /bin/dash.exe bin/
	cp /bin/regtool.exe bin/
	cp /bin/zoo.exe bin/

appx-bin:
	mkdir -p bin
	cp /bin/cygwin1.dll bin/
	cp /bin/cygwin-console-helper.exe bin/

cop:	ver
	mkdir -p rel
	rm -fr rel/wsltty-$(ver)-install.exe
	sed -e "s,%version%,$(ver)," makewinx.cfg > rel/wsltty.SED
	cp bin/cygwin1.dll rel/
	cp bin/cygwin-console-helper.exe rel/
	cp bin/dash.exe rel/
	cp bin/regtool.exe rel/
	cp bin/mintty.exe rel/
	cp bin/zoo.exe rel/
	cp lang.zoo rel/
	cp themes.zoo rel/
	cp charnames.txt rel/
	cp bin/wslbridge.exe rel/
	cp bin/wslbridge-backend rel/
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
appx:	wsltty-appx
	sh ./build.sh

#############################################################################
# end
