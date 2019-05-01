Mintty as a terminal for WSL (Windows Subsystem for Linux).

<img align=right src=wsltty.png>

### Overview ###

WSLtty components
* wsltty package components (see below) in the user’s local application folder 
  `%LOCALAPPDATA%`
* a wsltty configuration directory in the user’s application folder `%APPDATA%`
  (“home”-located configuration files from a previously installed version 
  will be migrated to the new default location)
* Start Menu shortcuts to start WSL terminals
* `*.bat` scripts to invoke WSL terminals from the command line
* optional context menu entries for Windows Explorer to start WSL terminals in the respective folder
* install/uninstall context menu items from Start Menu subfolder `WSLtty`

---

### Installation from this repository ###

#### WSLtty installer ([Download](https://github.com/mintty/wsltty/releases) standalone installation) ####

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

(For experts)
Within the installation process, provide parameters to the script `install.bat`.
The optional first parameter designates the installation target,
the optional second parameter designates the configuration directory.

### Installation with other package management environments ###

#### Chocolatey ####

If you use the [Chocolatey package manager](https://chocolatey.org/), 
invoke one of
<img height=222 align=right src=https://github.com/mintty/wsltty.appx/raw/master/wsltty.appx.png>
* `choco install wsltty`
* `choco upgrade wsltty`

#### Scoop ####

If you use the [Scoop package manager](https://scoop.sh/), 
* `scoop bucket add extras`

then, invoke one of
* `scoop install wsltty`
* `scoop update wsltty`

#### Windows Appx package ####

A Windows Appx package and certificate is available in the [wsltty.appx](https://github.com/mintty/wsltty.appx/) repository.

<br clear=all>

---

### Invocation ###

WSLtty can be invoked with
* installed Start Menu shortcuts (or Desktop shortcuts if copied there)
* *.bat scripts (optionally with WSL command as parameters)
* Explorer context menu (if installed from the Start Menu `WSLtty` subfolder)

Starting the mintty terminal directly from the WSLtty installation location 
is discouraged because that would bypass essential options.

---

### Configuration ###

#### Start Menu and Desktop shortcuts ####

In the Start Menu, the following shortcuts are installed:
* For each installed WSL distribution D, D` Terminal` to start in the WSL user home
* `WSL Terminal` to start the default WSL distribution (as configured with the Windows tool `wslconfig`)

In the Start Menu subfolder WSLtty, the following shortcuts are installed:
* For each installed WSL distribution D, D` Terminal %` to start in the Windows %USERPROFILE% home
* `WSL Terminal %` to start the default WSL distribution in the Windows %USERPROFILE% home

One Desktop shortcut is installed:
* `WSL Terminal` to start the default WSL distribution (as configured with the Windows tool `wslconfig`)

Other, distribution-specific shortcuts can be copied to the desktop 
from the Start Menu if desired.

The Start menu folder WSLtty contains the link 
<img align=absmiddle height=25 src=https://user-images.githubusercontent.com/12740416/57078483-a7846a00-6cee-11e9-9c5e-8c2e9e56cae4.png>`configure WSL shortcuts`.
This function is initially run when wsltty is installed.
If should be rerun after adding or removing WSL distributions, 
in order to create the respective set of shortcuts in the Start menu.

#### Command line scripts `wsl*.bat` ####

WSLtty installs the following scripts into `%LOCALAPPDATA%\Microsoft\WindowsApps` 
(and a copy in its application folder `%LOCALAPPDATA%\wsltty`):

* For each installed WSL distribution D, D`.bat` to start in the current folder/directory
* For each installed WSL distribution D, D`~.bat` to start in the WSL user home
* `WSL.bat` and `WSL~.bat` to start the default WSL distribution

Given that `%LOCALAPPDATA%\Microsoft\WindowsApps` is in your PATH,
the scripts can be invoked from cmd.exe, PowerShell, or via WIN+R.

#### Context menu entries ####

WSLtty provides context menu entries for all installed WSL distributions 
and one for the configured default distribution,
to start a respective WSL terminal in a specific folder from an Explorer window.
They are not installed by default.

To add launch entries for the default or all WSL distributions to the 
Explorer context menu, or remove them, run the respective script from the 
Start Menu subfolder `WSLtty`:
* <img align=absmiddle height=25 src=https://user-images.githubusercontent.com/12740416/57078483-a7846a00-6cee-11e9-9c5e-8c2e9e56cae4.png>`add default to context menu`
  adds context menu entries for the default WSL distribution
* <img align=absmiddle height=25 src=https://user-images.githubusercontent.com/12740416/57078483-a7846a00-6cee-11e9-9c5e-8c2e9e56cae4.png>`add to context menu`
  adds context menu entries for all WSL distributions
* <img align=absmiddle height=25 src=https://user-images.githubusercontent.com/12740416/57078483-a7846a00-6cee-11e9-9c5e-8c2e9e56cae4.png>`remove from context menu`
  removes context menu entries for WSL distributions

#### Icon ####

Wsltty installation and the mintty terminal try to use the icon of the 
respective WSL distribution. If it cannot be determined, a penguin icon 
is used as a default. You can replace it with your preferred fallback icon 
by replacing the icon file `%LOCALAPPDATA%\wsltty\wsl.ico`.

#### Mintty settings ####

Mintty can maintain its configuration file in various locations, 
with the following precedence:
* file given with mintty option `-c` (not used by wsltty default installation)
* file `config` in directory given with mintty option `--configdir`
  * This is `%APPDATA%\wsltty\config` in the default wsltty installation.
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

#### Shell selection and Login shell ####

The WSLtty deployment does not impose a shell preference anymore.
However, the intermediate gateways (`wslbridge` and its backend and the `bash.exe` Windows launcher) 
are also involved.

To invoke your favourite shell or launch the shell in login mode, 
you may append a shell pathname and an optional `-l` parameter 
to the mintty invocation (in shortcuts, scripts, or context menu entries):
* `%LOCALAPPDATA%\wsltty\bin\mintty.exe --WSL= --configdir="%APPDATA%\wsltty" /bin/bash -l`

---

### Components and Credits ###

For mintty, see the [Mintty homepage](http://mintty.github.io/) 
(with further screenshots), 
the [Mintty manual page](http://mintty.github.io/mintty.1.html), 
<br>and the [Mintty Wiki](https://github.com/mintty/mintty/wiki), 
including a [Hints and Tips page](https://github.com/mintty/mintty/wiki/Tips).

It is based on [Cygwin](http://cygwin.com) 
and includes its runtime library ([sources](http://mirrors.dotsrc.org/cygwin/x86/release/cygwin)).

For interacting with WSL, it uses [wslbridge](https://github.com/rprichard/wslbridge).
Many thanks for this enabling gateway go especially to Ryan Prichard.
