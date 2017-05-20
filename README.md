Mintty as a terminal for Bash on Ubuntu on Windows / WSL.

### Overview ###

WSLtty components
* wsltty package components (see below) in the user’s local application folder 
  `%LOCALAPPDATA%` (where WSL is also installed)
* a wsltty configuration directory in the user’s application folder `%APPDATA%`; 
  “home”-located configuration files from a previously installed version 
  will be migrated to the new default location
* Start Menu and Desktop shortcuts to start a WSL bash (with some variations, see below)
* optional context menu entries for Windows Explorer to start a WSL bash in the respective folder
* install/uninstall context menu items from Start Menu subfolder
* `wsl*.bat` scripts to invoke wsltty manually (with some variations and invocation options, see below)
* an uninstall script that can be invoked manually to remove shortcuts and context menu entries

### Installation ###

#### WSLtty installer ####

Run the [installer](https://github.com/mintty/wsltty/releases) to install 
the components listed above.
If Windows complains with a “Windows protected your PC” popup, 
you may need to click “Run anyway” to proceed with the installation.
You may need to open the Properties of the installer first, tab “General” 
section “Security” (if available) and select “Unblock”, 
to enable the “Run anyway” button.

#### Installation from source repository ####

Download or checkout the wsltty repository.
Invoke `make`, then `make install`.
Note this has to be done within a Cygwin environment.

#### Installation to non-default locations ####

Within the installation process, provide parameters to the script `install.bat`.
The optional first parameter designates the installation target,
the optional second parameter designates the configuration directory.

### Configuration ###

#### Command line scripts `wsl*.bat` ####

WSLtty installs the following scripts in its application folder `%LOCALAPPDATA%\wsltty`:
* `wsl.bat` to start a WSL bash in the current folder/directory
* `wsl~.bat` to start a WSL bash in the WSL user home
* `wsl-l.bat` to start a WSL login bash

To enable invocation of these scripts from WIN+R or from cmd.exe, 
copy them from `%LOCALAPPDATA%\wsltty` into `%SYSTEMROOT%\System32`, 
renaming them as desired.
(The package does not do this to avoid trouble with missing admin privileges.)

#### Start Menu and Desktop shortcuts ####

The Start Menu subfolder WSLtty offers three shortcuts:
* `WSL Bash % in Mintty` to start a WSL bash in the Windows %USERPROFILE% home
* `WSL Bash ~ in Mintty` to start a WSL bash in the WSL user home
* `WSL Bash -l in Mintty` to start a WSL login bash

To ensure a login bash to start in your Linux home directory, 
add a `cd` command to your `$HOME/.profile` on Linux side.

#### Mintty settings ####

Mintty can maintain its configuration file in various locations, 
with the following precedence:
* file given with mintty option `-c` (not used by wsltty default installation)
* file `config` in directory given with mintty option `--configdir`
  * This is `%APPDATA%\mintty\config` in the default wsltty installation.
* `%HOME%\.minttyrc` (usage deprecated with wsltty)
* `%HOME%\.config\mintty\config` (usage deprecated with wsltty)
* `%APPDATA%\mintty\config`
* `%LOCALAPPDATA%\wsltty\etc\minttyrc` (usage deprecated with wsltty)

Note:
* `%APPDATA%\wsltty\config` is the new user configuration file location. 
  Further subdirectories of `%APPDATA%\wsltty` are used for language, 
  themes, and sounds resource configuration. 
  Note the distinction from `%LOCALAPPDATA%\wsltty` which is the default 
  wsltty software installation location.
* The `%APPDATA%\mintty\config` option provides the possibility to 
  maintain common mintty settings for various installations (like 
  wsltty, Cygwin, MinGW/msys, Git for Windows, MinEd for Windows).
* (About deprecated options) By default, `%HOME%` would refer to the 
  root directory of the cygwin standalone installation hosting wsltty. 
  So `%HOME%` would mean `%LOCALAPPDATA%\wsltty\home\%USERNAME%`.
  If you define `HOME` at Windows level, this changes accordingly.
  Note, however, that the WSL `HOME` is a completely different setting.

#### Shell selection ####

To invoke your favourite shell, simply replace `/bin/bash` with its pathname 
in the Desktop shortcuts, `wsl*.bat` invocation scripts, 
or Explorer context menu commands (configured in `config-context-menu.bat`).

### Components ###

For mintty, see the [Mintty homepage](http://mintty.github.io/), 
then [Mintty manual page](http://mintty.github.io/mintty.1.html), 
and the [Mintty Wiki](https://github.com/mintty/mintty/wiki), 
including a [Hints and Tips page](https://github.com/mintty/mintty/wiki/Tips).

It is based on [Cygwin](http://cygwin.com) 
and includes its runtime library ([sources](http://mirrors.dotsrc.org/cygwin/x86/release/cygwin)).

For interacting with WSL, it uses [wslbridge](https://github.com/rprichard/wslbridge).

