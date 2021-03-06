#!/bin/bash

casks=(
	# Apps
	adium
	alfred
	brackets
	cocoarestclient
	colloquy
	colors
	dropbox
	firefox
	fluid
	google-chrome
	handbrake
	iexplorer
	iphone-configuration-utility
	iterm2-nightly
	mou
	reveal
	sequel-pro
	skype
	sourcetree
	spotify
	steam
	sublime-text
	textmate
	transmission
	truecrypt
	unrarx
	virtualbox
	vlc

	# Fonts
	font-sauce-code-powerline

	# Quicklook plugins
	betterzipql
	qlmarkdown
	qlstephen
	qlcolorcode
	quicklook-json
	qlprettypatch
	quicklook-csv
	suspicious-package
	webp-quicklook
)
brews=(
	cloc
	git
	ios-sim
	npm
	python
	spark
	tmux
	tree
	wget
)
rgems=(
	cocoapods
	compass
	lolcat
	nomad-cli
	pygmentize
)
nodes=(
	cordova
	jslint
	nd
)

echo ''
echo ' ***** New machine setup script ***** '
echo ''
echo 'You should have followed the manual instructions first, or at least'
echo 'installed Xcode and its command line utilities.'
echo ''
echo 'This script will install the following software, mostly WITHOUT PROMPTS'
echo '(will pause on errors)'
echo ''
echo 'General:'
echo ' * Change computer name (optional)'
echo ' * General OSX configuration'
echo ' * Solarized editor themes'
echo ''
echo 'GUI software:'
echo ' * iTerm 2 Nightly'
for i in "${casks[@]}"; do :
	echo ' * '$i
done
echo ''
echo 'Server software:'
echo ' * MySql'
echo ' * Apache and PHP configuration'
echo ''
echo 'CLI software:'
echo ' * Homebrew'
echo ' * RVM (optional)'
for i in "${brews[@]}"; do :
	echo ' * '$i
done
for i in "${rgems[@]}"; do :
	echo ' * '$i
done
for i in "${nodes[@]}"; do :
	echo ' * '$i
done
echo ''
echo 'CLI environment:'
echo ' * Oh-My-ZSH'
echo ' * Powerline plus modified fonts'
echo ''

if [[ $UID == 0 ]]; then
	echo ''
	echo 'This script should not be run as sudo. Exiting...'
	echo ''
	exit 1
fi

read -p "Have you installed Xcode and/or the command line tools?" -n 1 -r
echo ''
echo ''
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo 'A popup will appear asking to install Command Line developer tools. Select Install.'
	
	# `gcc` or `make` will prompt OS X to download command line tools
	gcc

	# probably a more intelligent way of detecting if installed...
	read -p 'When installed press [ENTER] to continue' -n1 -s
	echo ''
	echo ''

fi

read -p 'Are you sure you wish to proceed with this script? ' -n 1 -r
echo ''
echo ''
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	exit 1
fi



# Call external script to set OSX options
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sh $DIR/OSX_Config.sh



# Set up Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew doctor
brew tap caskroom/cask
brew tap caskroom/fonts
brew tap caskroom/versions
brew install brew-cask



# Install commonly used brew recipes
# Full list at https://github.com/mxcl/homebrew/tree/master/Library/Formula
for i in "${brews[@]}"; do :
	brew install $i
	echo ''
done



# Use Homebrew to install common GUI applications
# Full list at https://github.com/caskroom/homebrew-cask/tree/master/Casks
# Will prompt for sudo for first cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
for i in "${casks[@]}"; do :
	brew cask install $i 2> /dev/null
	echo ''
done
# Restart the QuickLook manager to pick up new plugins
qlmanage -r


# Link casks directory to Alfred
for i in "${casks[@]}"; do :
	if [[ "$i" == "alfred2" ]]; then
		if [[ `brew cask alfred status` ]]; then
			echo -e '\nLaunch Alfred to initialise preferences before continuing.\n\n'
			read -p 'Press any key to continue' -n 1 -s
			echo ''
			brew cask alfred link
		else
			echo -e "If integration is required, add /opt/homebrew-cask/Caskroom to Alfred's search paths\n"
			read -p 'Press any key to continue' -n 1 -s
			echo ''
		fi
	fi
done



# Install RVM, create a default gemset and install the listed gems
echo ''
read -p 'Install RVM? ' -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]; then
	# export rvm_ignore_dotfiles=yes
	curl -L https://get.rvm.io | bash -s stable --ruby=1.9.3
	source ~/.rvm/scripts/rvm
	rvm --create 1.9.3@default-gemset
	rvm use 1.9.3@default-gemset --default

fi
for i in "${rgems[@]}"; do :
	sudo gem install $i
	echo ''
done



# Install any configured node.js packages
if hash npm 2>/dev/null; then
	echo -e '\nInstalling Node.js packages...\n'
	for i in "${nodes[@]}"; do :
		npm install -g $i
		echo ''
	done
else
	echo -e '\nNode.js not installed/working, cannot install packages\n\n'
	read -p 'Press any key to continue' -n 1 -s
	echo ''
fi



# Install MySql from Brew and setup to run correctly
echo ''
read -p 'Install and configure MySQL? ' -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]; then
	sudo sed -i '' 's/;extension=php_mysql\./extension=php_mysql\./g' /etc/php.ini
	brew install mysql
	# Setup daemon
	mkdir -p ~/Library/LaunchAgents
	ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents/
	launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
	# Start MySql server and run secure script
	mysql.server start
	mysql_secure_installation
	echo ''
	echo 'If mysql_secure_installation failed to run, execute it manually now'
	echo ''
	read -p 'Press any key to continue..' -n 1 -r
fi



# Configure Apache and PHP
sudo chmod -R o+w /Library/WebServer/Documents
sudo sed -i '' 's/#LoadModule php5/LoadModule php5/g' /etc/apache2/httpd.conf
echo "<?php phpinfo(); ?>" | sudo tee /Library/WebServer/Documents/phpinfo.php
sudo cp /etc/php.ini.default /etc/php.ini
sudo sed -i '' 's/display_errors = Off/display_errors = On/g' /etc/php.ini
sudo sed -i '' 's/html_errors = Off/html_errors = On/g' /etc/php.ini
sudo sed -i '' 's/mysql.default_socket = \/var\/mysql\/mysql.sock/mysql.default_socket = \/tmp\/mysql.sock/g' /etc/php.ini
sudo apachectl restart



# Create code folder tree
# TODO: "Projects" should be symlinked here, but we haven't set up Dropbox yet
echo -e '\n\nSetting up Code folder structure..'
mkdir -p ~/Code/CodeDownloads
mkdir -p ~/Code/Libraries
mkdir -p ~/Code/Resources
mkdir -p ~/Code/SDKs
mkdir -p ~/Code/TerminalUtils
mkdir -p ~/Code/TestProjects
mkdir -p ~/Code/WorkProjects


# Clones common projects/libraries
sh $DIR/CodeClones.sh



# Clone command line tools
echo -e '\n\nCloning terminal utilities'
pushd ~/Code/TerminalUtils
git clone https://github.com/robbyrussell/oh-my-zsh.git
git clone https://github.com/altercation/solarized.git
popd


echo -e '\nIf you have any backed up dotfiles you should set them up now\n'
read -p 'Press any key when ready' -n 1 -s
echo ''


# We need to modify the path to point to brew first - this is in dotfiles but they won't have been loaded yet
PATH="/usr/local/bin:$PATH"


# Generate new SSH key
echo ''
read -p 'Generate new SSH keypair? ' -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]; then
	ssh-keygen -t rsa
	ssh-add ~/.ssh/id_rsa
	pbcopy < ~/.ssh/id_rsa.pub
	echo -e '\nPublic key copied to clipboard\n'
fi


# Set up command line tools
echo -e '\nSetting up Powerline\n'
pip install git+git://github.com/Lokaltog/powerline
pip install psutil
echo -e '\n*** Remember to set Terminal/iTerm font to Source Code Pro ***'

echo -e '\nInstalling vim supporting Python'
brew install vim --env-std --override-system-vim --enable-pythoninterp

echo -e '\nSetting ZSH as default shell'
chsh -s `which zsh`
/usr/bin/env zsh
source ~/.zshrc

# Download Solarized for Xcode
mkdir -p ~/Library/Developer/Xcode/UserData/FontAndColorThemes
wget "https://raw.githubusercontent.com/ArtSabintsev/Solarized-Dark-for-Xcode/master/Solarized%20Dark%20@ArtSabintsev.dvtcolortheme" -P ~/Library/Developer/Xcode/UserData/FontAndColorThemes

# Fix commands like pbcopy when used in tmux
brew install reattach-to-user-namespace --wrap-pbcopy-and-pbpaste

# Add option to install Android SDK
echo ''
read -p 'Install Android SDK?' -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]; then
	brew install android-sdk
	android update sdk --no-ui --filter 'platform-tools'
fi