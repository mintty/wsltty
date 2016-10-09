#############################################################################
# default: generate all
all:	wslbridge mintty cygwin wsltty pkg

ver=0.6.2
wslbridgever=0.2.0

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

wget=curl -R -L -O --connect-timeout 55

#############################################################################
# generation

wslbridge:
	$(wget) https://github.com/rprichard/wslbridge/releases/download/$(wslbridgever)/wslbridge-$(wslbridgever)-$(sys).tar.gz
	tar xvzf wslbridge-$(wslbridgever)-$(sys).tar.gz
	mkdir -p bin
	cp wslbridge-$(wslbridgever)-$(sys)/wslbridge* bin/
	cp wslbridge-$(wslbridgever)-$(sys)/LICENSE.txt LICENSE.wslbridge

mintty:
	$(wget) https://github.com/mintty/mintty/archive/master.zip
	mv master.zip mintty-master.zip
	unzip -o mintty-master.zip
	cd mintty-master; patch -p0 -i ../mintty_drag_drop_file.patch
	cd mintty-master/src; make LDFLAGS="-static -static-libgcc -s"
	mkdir -p bin
	cp mintty-master/bin/mintty.exe bin/
	cp mintty-master/LICENSE LICENSE.mintty

cygwin:
	mkdir -p bin
	cp /bin/cygwin1.dll bin/
	cp /bin/cygwin-console-helper.exe bin/
	#cp /bin/dash.exe bin/

wsltty:

pkg:
	mkdir -p rel
	sed -e "s,%version%,$(ver)," makewinx.cfg > rel/wsltty.SED
	cp bin/cygwin1.dll rel/
	cp bin/cygwin-console-helper.exe rel/
	#cp bin/dash.exe rel/
	cp bin/mintty.exe rel/
	cp bin/wslbridge.exe rel/
	cp bin/wslbridge-backend rel/
	cp LICENSE.mintty rel/
	cp LICENSE.wslbridge rel/
	cp "Bash on UoW in Mintty.lnk" rel/
	cp wsl.bat rel/
	cp install.bat rel/
	cp uninstall.bat rel/
	cd rel; iexpress /n wsltty.SED

#############################################################################
# end
