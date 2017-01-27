#############################################################################
# default: generate all
all:	check pkg

# wsltty release
ver=0.7.4

# mintty release version
minttyver=2.7.4
#minttyver=master

# wslbridge backend version
wslbridgever=0.2.1
# wslbridge frontend version
# release 0.2.0 does not have cygwin_internal(CW_SYNC_WINENV) yet;
# therefore using "master" below
#wslbridge-frontend=wslbridge-frontend
# release 0.2.1 is updated and complete, no separate frontend build needed:
wslbridge-frontend=

help:
	echo configure `ver=...` and `minttyver=` in this makefile
	echo run `make` to build a distributable installer
	echo run `make pkg` to build an installer, bypassing the system checks
	echo run `make wsltty` to build an installer using the local copy of mintty

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
# system check;
# for now, let's enforce Cygwin 32-Bit as the container for wsltty
# just in case there is a 32-Bit WSL released (-> 32 bit), and to ensure 
# the path name drag-and-drop adaptation works (-> cygwin, not msys)

check:
	# checking suitable host environment; run `make pkg` to bypass
	# check cygwin (vs msys) for proper drag-and-drop paths:
	uname | grep CYGWIN
	# check 32 bit (vs 64 bit) to ensure 32-Bit Windows support, just in case:
	uname -m | grep i686

#############################################################################
# generation

wslbridge:	wslbridge-backend $(wslbridge-frontend)

wslbridge-backend:
	$(wget) https://github.com/rprichard/wslbridge/releases/download/$(wslbridgever)/wslbridge-$(wslbridgever)-$(sys).tar.gz
	tar xvzf wslbridge-$(wslbridgever)-$(sys).tar.gz
	mkdir -p bin
	cp wslbridge-$(wslbridgever)-$(sys)/wslbridge* bin/
	cp wslbridge-$(wslbridgever)-$(sys)/LICENSE.txt LICENSE.wslbridge

wslbridge-frontend:
	$(wgeto) https://github.com/rprichard/wslbridge/archive/master.zip -o wslbridge-master.zip
	unzip -o wslbridge-master.zip
	cd wslbridge-master/frontend; make
	strip wslbridge-master/out/wslbridge.exe
	mkdir -p bin
	cp wslbridge-master/out/wslbridge.exe bin/
	cp wslbridge-master/LICENSE.txt LICENSE.wslbridge

mintty:	mintty-get mintty-build

mintty-get:
	$(wgeto) https://github.com/mintty/mintty/archive/$(minttyver).zip -o mintty-$(minttyver).zip
	unzip -o mintty-$(minttyver).zip

mintty-build:
	cd mintty-$(minttyver)/src; make LDFLAGS="-static -static-libgcc -s"
	mkdir -p bin
	cp mintty-$(minttyver)/bin/mintty.exe bin/
	cp mintty-$(minttyver)/LICENSE LICENSE.mintty
	cd mintty-$(minttyver)/lang; zoo a po *.po; mv po.zoo ../../

cygwin:
	mkdir -p bin
	cp /bin/cygwin1.dll bin/
	cp /bin/cygwin-console-helper.exe bin/
	#cp /bin/dash.exe bin/
	cp /bin/zoo.exe bin/

cab:
	mkdir -p rel
	rm -fr rel/wsltty-$(ver)-install.exe
	sed -e "s,%version%,$(ver)," makewinx.cfg > rel/wsltty.SED
	cp bin/cygwin1.dll rel/
	cp bin/cygwin-console-helper.exe rel/
	#cp bin/dash.exe rel/
	cp bin/mintty.exe rel/
	cp bin/zoo.exe rel/
	cp po.zoo rel/
	cp bin/wslbridge.exe rel/
	cp bin/wslbridge-backend rel/
	cp LICENSE.* rel/
	cp *.lnk rel/
	cp *.url rel/
	cp *.bat rel/
	cd rel; iexpress /n wsltty.SED

pkg:	wslbridge cygwin mintty cab

wsltty:	wslbridge cygwin mintty-build cab

#############################################################################
# end
