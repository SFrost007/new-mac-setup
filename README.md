New Mac Setup
=============

These scripts automatically install a significant quantity of day-to-day development tools and commonly used software on a fresh OS X image, in addition to setting almost all built-in OS X options to (my!) desired values.

Error checking is currently minimal, but this has been developed/tested on a clean Mountain Lion (10.8.4) installation. The only pre-requisite is to install Xcode and its associated "Command Line Tools" to allow several of the tools to be built.

Much of the script is non-interactive and non-prompting; for variation you should edit the script(s) after cloning.

While it's likely a bad idea to attempt to list the software installed within this readme, this is a summary of the software installed as of the initial commit.


Package Managers
================
* [Homebrew](http://brew.sh/)
* [Homebrew Cask](https://github.com/phinze/homebrew-cask) - For GUI applications
* [NPM](https://npmjs.org/)
* [RVM](https://rvm.io/) - (Optional)


Command Line Utilities
======================
* [cloc](http://cloc.sourceforge.net/) - Count Lines of Code
* [compass](http://compass-style.org/) - CSS Preprocessor
* [cordova](http://cordova.apache.org/) - Mobile application platform
* [git](http://git-scm.com/) - Source control (more recent version than Xcode)
* [ios-sim](https://github.com/phonegap/ios-sim) - Launch iOS Simulator from Terminal
* [nomad-cli](http://nomad-cli.com/) - iOS build/distribution helper
* [pygmentize](http://pygments.org/docs/cmdline/) - Syntax highlighter
* [tmux](http://tmux.sourceforge.net/) - Terminal Multiplexer
* [tree](http://mama.indstate.edu/users/ice/tree/) - Directory lister
* [wget](http://www.gnu.org/software/wget/) - HTTP client


GUI Software
============
* [Adium](https://adium.im/) - Chat client
* [Cocoa Rest Client](https://code.google.com/p/cocoa-rest-client/) - For testing REST endpoints
* [Daisy Disk](http://www.daisydiskapp.com/) - Disk space visualiser
* [DiffMerge](http://www.sourcegear.com/diffmerge/) - Diff viewer
* [Dropbox](https://www.dropbox.com/) - File synchronisation
* [Fluid](http://fluidapp.com/) - Web app wrapper generator
* [Google Chrome](https://www.google.com/chrome) - Web browser
* [Handbrake](http://handbrake.fr/) - Video transcoder
* [iExplorer](http://www.macroplant.com/iexplorer/) - iOS device manager
* [iTerm 2](http://www.iterm2.com/) - Terminal emulator
* [iPhone Configuration Utility](http://support.apple.com/kb/DL1465) - iOS installation manager
* [Phone Clean](http://www.imobie.com/phoneclean/) - iOS space reclaimer
* [Sequel Pro](http://www.sequelpro.com/) - MySQL manager
* [SourceTree](http://www.sourcetreeapp.com/) - Git & Mercurial client
* [Spotify](https://www.spotify.com) - Streaming music client
* [Steam](http://store.steampowered.com/) - Gaming platform
* [TextMate 2](http://macromates.com/) - Text editor
* [Transmission](http://www.transmissionbt.com/) - Bittorrent client
* [UnrarX](http://www.unrarx.com/) - Archive utility
* [VirtualBox](https://www.virtualbox.org/) - Virtualisation
* [VLC](http://www.videolan.org/vlc/index.html) - Media player


OSX Configuration
=================
* Setting hostname via prompt (optional)
* Generate new SSH keypair (optional)
* Installation of British-PC keyboard layout
* QuickLook helpers for Markdown and plain-text with no extension (e.g. README)
* Apache/PHP/MySQL configuration
* __MANY__ other small tweaks/settings


Command Line Environment
========================
* Clones:
	* [Oh-My-ZSH](https://github.com/robbyrussell/oh-my-zsh)
	* [Oh-My-ZSH Powerline](https://github.com/jeremyFreeAgent/oh-my-zsh-powerline-theme)
	* [Powerline](https://github.com/Lokaltog/powerline)
	* [Powerline modified fonts](https://github.com/Lokaltog/powerline-fonts)
	* [Solarized editor themes](http://ethanschoonover.com/solarized)
* Installs OMZ Powerline theme
* Sets ZSH as default shell