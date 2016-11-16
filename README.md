Mintty as a terminal for Bash on Ubuntu on Windows / WSL.

### Overview ###

Run the [installer](https://github.com/mintty/wsltty/releases) to install
* wsltty package components (see below) in the user’s application folder (where WSL is also installed)
* an empty wsltty “home directory” to enable storage of a mintty config file
* Start Menu and Desktop shortcuts to start a WSL bash (with some variations, see below)
* optional context menu entries for Windows Explorer to start a WSL bash in the respective folder, installable from the Start Menu subfolder
* `wsl*.bat` scripts to invoke wsltty manually (with some variations and invocation options, see below)
* an uninstall script that can be invoked manually to remove shortcuts and context menu entries

### Configuration ###

#### Command line scripts wsl*.bat ####

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
* file given with mintty option `-c`
* `%LOCALAPPDATA%\wsltty\home\%USERNAME%\.minttyrc`
* `%LOCALAPPDATA%\wsltty\home\%USERNAME%\.config\mintty\config`
* `%APPDATA%\mintty\config`
* `%LOCALAPPDATA%\wsltty\etc\minttyrc`

Note that the `%APPDATA%\mintty\config` option provides the possibility 
to maintain common mintty settings for various installations (like 
wsltty, Cygwin, MinGW/msys, Git for Windows, MinEd for Windows).

### Components ###

For mintty, see the [Mintty homepage](http://mintty.github.io/).

It is based on [Cygwin](http://cygwin.com) 
and includes its runtime library ([sources](http://mirrors.dotsrc.org/cygwin/x86/release/cygwin)).

For interacting with WSL, it uses [wslbridge](https://github.com/rprichard/wslbridge).

