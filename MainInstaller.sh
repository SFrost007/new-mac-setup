#!/bin/bash

#  - TODO: Powerline for tmux

casks=(adium cocoa-rest-client daisy-disk diffmerge dropbox fluid google-chrome handbrake i-explorer iphone-configuration-utility phone-clean sequel-pro sourcetree spotify steam textmate transmission unrarx vlc)
brews=(cloc ios-sim npm tmux tree wget)
rgems=(compass nomad-cli pygmentize)
nodes=(cordova)

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
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
brew doctor



# Install commonly used brew recipes
# Full list at https://github.com/mxcl/homebrew/tree/master/Library/Formula
for i in "${brews[@]}"; do :
	brew install $i
	echo ''
done



# Use Homebrew to install common GUI applications
# Full list at https://github.com/phinze/homebrew-cask/tree/master/Casks
# Will prompt for sudo for first cask
brew tap phinze/homebrew-cask
brew install brew-cask
echo ''
if [ `brew cask alfred status` ]; then
	brew cask alfred link
else
	echo -e "If integration is required, add /opt/homebrew-cask/Caskroom to Alfred's search paths\n"
	read -p 'Press any key to continue' -n 1 -s
	echo ''
fi
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
for i in "${casks[@]}"; do :
	brew cask install $i 2> /dev/null
	echo ''
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
	gem install $i
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
brew install mysql
# Setup daemon
mkdir -p ~/Library/LaunchAgents
ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
# Start MySql server and run secure script
mysql.server start
mysql_secure_installation



# Configure Apache and PHP
sudo chmod -R o+w /Library/WebServer/Documents
sudo sed -i '' 's/#LoadModule php5/LoadModule php5/g' /etc/apache2/httpd.conf
echo "<?php phpinfo(); ?>" | sudo tee /Library/WebServer/Documents/phpinfo.php
sudo cp /etc/php.ini.default /etc/php.ini
sudo sed -i '' 's/;extension=php_mysql\./extension=php_mysql\./g' /etc/php.ini
sudo sed -i '' 's/display_errors = Off/display_errors = On/g' /etc/php.ini
sudo sed -i '' 's/html_errors = Off/html_errors = On/g' /etc/php.ini
sudo sed -i '' 's/mysql.default_socket = \/var\/mysql\/mysql.sock/mysql.default_socket = \/tmp\/mysql.sock/g' /etc/php.ini
sudo apachectl restart



# Manually install latest iTerm nightly as brew-cask prefers stable
echo -e '\n\n\nFetching latest iTerm2 nightly release...\n'
wget http://www.iterm2.com/nightly/latest -O iTerm.zip
if [ -f iTerm.zip ]; then
	unzip -q iTerm.zip && rm iTerm.zip
	mv iTerm.app /Applications
	echo -e '\nInstalled iTerm 2 to /Applications\n'
else
	echo -e '\n ***** Failed to download iTerm nightly, falling back to brew cask ***** \n'
	brew cask install iterm2 2> /dev/null
	echo ''
fi



# Install QuickLook plugins for non-extensioned files (README) and Markdown
# Xcode now supplies a syntax-highlighted code viewer plugin.
echo -e '\n\nInstalling extra QuickLook plugins...\n'
mkdir -p ~/Library/QuickLook
wget https://github.com/downloads/whomwah/qlstephen/QLStephen.qlgenerator.zip
if [ -f QLStephen.qlgenerator.zip ]; then
	unzip -q QLStephen.qlgenerator.zip && rm QLStephen.qlgenerator.zip
	mv QLStephen.qlgenerator ~/Library/QuickLook
	echo -e '\nInstalled plugin for plain text files (README etc)\n'
else
	echo -e '\n ***** Failed to download QuickLook plugin for plain text files ***** \n'
	read -p 'Press any key to continue' -n 1 -s
	echo ''
fi
wget https://github.com/downloads/toland/qlmarkdown/QLMarkdown-1.3.zip
if [ -f QLMarkdown-1.3.zip ]; then
	unzip -q QLMarkdown-1.3.zip && rm QLMarkdown-1.3.zip
	mv QLMarkdown/QLMarkdown.qlgenerator ~/Library/QuickLook
	rm -rf QLMarkdown
	echo -e '\nInstalled plugin for Markdown files\n'
else
	echo -e '\n ***** Failed to download QuickLook plugin for Markdown files ***** \n'
	read -p 'Press any key to continue' -n 1 -s
	echo ''
fi
rm -rf __MACOSX
qlmanage -r




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



# Clone command line tools
echo -e '\n\nCloning terminal utilities'
pushd ~/Code/TerminalUtils
git clone https://github.com/robbyrussell/oh-my-zsh.git
git clone https://github.com/jeremyFreeAgent/oh-my-zsh-powerline-theme.git
git clone https://github.com/Lokaltog/powerline.git
git clone https://github.com/Lokaltog/powerline-fonts.git
git clone https://github.com/altercation/solarized.git
popd


echo -e '\nIf you have any backed up dotfiles you should set them up now\n'
read -p 'Press any key when ready' -n 1 -s
echo ''


# Set up command line tools
echo -e '\nSetting up Powerline'
echo -e 'Remember to set Terminal/iTerm font to Source Code Pro'
ln -f ~/Code/TerminalUtils/oh-my-zsh-powerline-theme/powerline.zsh-theme ~/Code/TerminalUtils/oh-my-zsh/themes/
cp ~/Code/TerminalUtils/powerline-fonts/SourceCodePro/*.otf ~/Library/Fonts

echo -e '\nSetting ZSH as default shell'
chsh -s `which zsh`
/usr/bin/env zsh
source ~/.zshrc


# Generate new SSH key
echo ''
read -p 'Generate new SSH keypair? ' -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]; then
	ssh-keygen -t rsa
	pbcopy < ~/.ssh/id_rsa.pub
	echo -e '\nPublic key copied to clipboard\n'
fi
