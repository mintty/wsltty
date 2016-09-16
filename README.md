Mintty as a terminal for Bash on Ubuntu on Windows / WSL.

#### Overview ####

Run the [installer](https://github.com/mintty/wsltty/releases) to install
* wsltty package components (see below) in the user’s application directory (where WSL is also installed)
* an empty “home directory” to enable storage of a mintty config file
* a Desktop Shortcut and a Start Menu Shortcut to start WSL with a login bash in the user’s WSL home directory
* context menu entries for Windows Explorer to start WSL with a bash in the respective directory

An uninstaller is not provided.

#### Components ####

For mintty, see the [Mintty homepage](http://mintty.github.io/).

It is based on [Cygwin](http://cygwin.com) 
and includes its runtime library ([sources](http://mirrors.dotsrc.org/cygwin/x86/release/cygwin)).

For interacting with WSL, it uses [wslbridge](https://github.com/rprichard/wslbridge).

