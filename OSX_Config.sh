#!/bin/bash

# Script to set as many OSX configuration options as possible.
# Several of these configurations only take effect after a reboot.
# Cribbed together mostly from mathiasbynens:
#  * https://github.com/mathiasbynens/dotfiles/blob/master/.osx
#
# Other good sources:
#  * http://www.defaults-write.com/tag/10-8/
#  * http://secrets.blacktree.com/ (Seems slightly outdated)
#  * https://github.com/ptb/Mac-OS-X-Lion-Setup/blob/master/setup.sh
#  * https://github.com/davelens/dotfiles/blob/master/osx/defaults-overrides
#  * https://gist.github.com/saetia/1623487
#  * http://chris-gerke.blogspot.co.uk/2012/03/mac-osx-soe-master-image-day-6.html



###############################################################################
# General System stuff
###############################################################################
echo 'Setting general system options, will require root..'

# Disables GateKeeper (app signing checks)
sudo spctl --master-disable

# Allow computer name to be set if required
read -p 'Change computer name? ' -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]; then
	read -p 'Enter new computer name: ' -r
	if [[ $REPLY =~ ^[a-zA-Z0-9\_\-]+$ ]]; then
		echo 'Changing computer name to' $REPLY
		sudo scutil --set ComputerName $REPLY
		sudo scutil --set HostName $REPLY
		sudo scutil --set LocalHostName $REPLY
		sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $REPLY
	else
		echo 'Invalid computer name entered, skipping'
	fi
	echo ''
fi

# TimeMachine: Prevent prompting for use of new drives for backup
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Enable font smoothing on external monitors
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Enable built-in Apache to start at boot
sudo defaults write /System/Library/LaunchDaemons/org.apache.httpd Disabled -bool false

# Show system info on login screen (when clicking clock)
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Hide user-specific Applications folder
chflags hidden ~/Applications




###############################################################################
# Power management
###############################################################################
echo 'Setting power options..'

# Battery
sudo pmset -b sleep 30
sudo pmset -b displaysleep 10

# AC Power
sudo pmset -c sleep 0
sudo pmset -c displaysleep 60

# Screensaver password requirement
defaults write com.apple.screensaver 'askForPassword' -int 1
defaults write com.apple.screensaver 'askForPasswordDelay' -int 10




###############################################################################
# Menu bar configuration
###############################################################################
echo 'Setting menu bar preferences..'

defaults -currentHost write com.apple.systemuiserver 'dontAutoLoad' -array-add '/System/Library/CoreServices/Menu Extras/TimeMachine.menu'
defaults -currentHost write com.apple.systemuiserver 'dontAutoLoad' -array-add '/System/Library/CoreServices/Menu Extras/User.menu'
defaults -currentHost write com.apple.systemuiserver 'dontAutoLoad' -array-add '/System/Library/CoreServices/Menu Extras/Volume.menu'

# Set clock format to hh:mm
defaults write com.apple.menuextra.clock 'DateFormat' -string 'HH:mm'




###############################################################################
# Input hardware
###############################################################################
echo 'Setting input preferences..'

# Trackpad: Correct scroll direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: Set mouse speed
defaults write NSGlobalDomain com.apple.mouse.scaling -float 1.5
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3

# Keyboard: Enable key repeat rather than input menu
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Keyboard: Enable tab-focusing in dialogs
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Keyboard: Swap command and control when using a Microsoft Natural keyboard
# (To find out the numeric code for other keyboards, manually change the setting and run defaults -currentHost read -g)
defaults -currentHost write NSGlobalDomain com.apple.keyboard.modifiermapping.1118-1821-0 '
(
	{
		HIDKeyboardModifierMappingDst = 4;
		HIDKeyboardModifierMappingSrc = 2;
	}, {
		HIDKeyboardModifierMappingDst = 12;
		HIDKeyboardModifierMappingSrc = 10;
	}, {
		HIDKeyboardModifierMappingDst = 2;
		HIDKeyboardModifierMappingSrc = 4;
	}, {
		HIDKeyboardModifierMappingDst = 10;
		HIDKeyboardModifierMappingSrc = 12;
	}
)'

# Enable input menu on login screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool "TRUE"
sudo defaults write /var/ard/Library/Preferences/com.apple.menuextra.textinput ModeNameVisible -bool "TRUE"

# Keyboard: Enable British-PC layout
# To modify for other layouts, manually enable the layout and check for the name/ID in
# ~/Library/Preferences/ByHost/com.apple.HIToolbox*.plist
# NOTE: This will only work if there is only one current keyboard layout ('1' in each command is array index)
KB_LAYOUT_NAME="British-PC"
KB_LAYOUT_ID=250
KB_LAYOUT_FILES=$(ls ~/Library/Preferences/ByHost/com.apple.HIToolbox.*.plist)
for i in "${KB_LAYOUT_FILES[@]}"; do :
	/usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:1:InputSourceKind string Keyboard\ Layout" $i
	/usr/libexec/PlistBuddy -c "Set :AppleEnabledInputSources:1:InputSourceKind Keyboard\ Layout" $i
	/usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:1:KeyboardLayout\ ID integer ${KB_LAYOUT_ID}" $i
	/usr/libexec/PlistBuddy -c "Set :AppleEnabledInputSources:1:KeyboardLayout\ ID ${KB_LAYOUT_ID}" $i
	/usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:1:KeyboardLayout\ Name string ${KB_LAYOUT_NAME}" $i
	/usr/libexec/PlistBuddy -c "Set :AppleEnabledInputSources:1:KeyboardLayout\ Name ${KB_LAYOUT_NAME}" $i
	/usr/libexec/PlistBuddy -c "Add :AppleSelectedInputSources:1:InputSourceKind string Keyboard\ Layout" $i
	/usr/libexec/PlistBuddy -c "Set :AppleSelectedInputSources:1:InputSourceKind Keyboard\ Layout" $i
	/usr/libexec/PlistBuddy -c "Add :AppleSelectedInputSources:1:KeyboardLayout\ ID integer ${KB_LAYOUT_ID}" $i
	/usr/libexec/PlistBuddy -c "Set :AppleSelectedInputSources:1:KeyboardLayout\ ID ${KB_LAYOUT_ID}" $i
	/usr/libexec/PlistBuddy -c "Add :AppleSelectedInputSources:1:KeyboardLayout\ Name string ${KB_LAYOUT_NAME}" $i
	/usr/libexec/PlistBuddy -c "Set :AppleSelectedInputSources:1:KeyboardLayout\ Name ${KB_LAYOUT_NAME}" $i
done

# Keyboard: Enable the input language switcher
# FIXME: This will add a duplicate if the icon already exists
defaults write com.apple.systemuiserver 'menuExtras' -array-add '/System/Library/CoreServices/Menu Extras/TextInput.menu'




###############################################################################
# Finder
###############################################################################
echo 'Setting Finder preferences..'

# Set new window default location to home folder
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Make sidebar icons smaller
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Show connected servers and removable media on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Show filename extensions, and disable warning when changing extension
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show status bar and path bar
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Allow text selection in QuickLook
defaults write com.apple.finder QLEnableTextSelection -bool true

# Search in the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoid creating .DS_Store files on network stores
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Skip verifying disk images
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Disable the 'This file was downloaded' dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Automatically open a new window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Set default view mode to grid for desktop and list elsewhere
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy list" ~/Library/Preferences/com.apple.finder.plist
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library

# Show all files
#defaults write com.apple.finder AppleShowAllFiles -bool true




###############################################################################
# Dock
###############################################################################
echo 'Setting Dock preferences..'

# Move the dock to the left
defaults write com.apple.dock orientation -string "left"

# Make the dock icons a bit smaller
defaults write com.apple.dock tilesize -int 36

# Enable dock magnification
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -float 80

# Set highlight when hovering over stack items
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Ensure running app indicators are visible
defaults write com.apple.dock show-process-indicators -bool true

# Minimise windows into dock icon
defaults write com.apple.dock minimize-to-application -bool true

# Dim icons of hidden apps in dock
defaults write com.apple.dock showhidden -bool true

# Clear out all standard dock icons, and add a few spacer items
# Destructive if script is run again, so move behind prompt
read -p 'Reset Dock items? ' -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]; then
	defaults write com.apple.dock persistent-apps -array
	defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
	defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
	defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
	killall Dock
fi




###############################################################################
# Mission Control/Expose/Hot Corners
###############################################################################
echo 'Setting Mission Control preferences..'

# Disable Dashboard and remove from Spaces
defaults write com.apple.dashboard mcx-disabled -bool true
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Set up hot corners
defaults write com.apple.dock wvous-tl-corner -int 2	# Mission control
defaults write com.apple.dock wvous-tr-corner -int 4	# Desktop
defaults write com.apple.dock wvous-bl-corner -int 10	# Turn off screen
defaults write com.apple.dock wvous-br-corner -int 5	# Screensaver




###############################################################################
# Misc apps
###############################################################################
echo 'Setting miscellaneous app preferences..'

# TextEdit: Default to plain text
#defaults write com.apple.TextEdit RichText -int 0

# TextEdit: Hide the ruler as default
#defaults write com.apple.TextEdit ShowRuler 0

# Terminal: Default to UTF8?
# defaults write com.apple.terminal StringEncodings -array 4

# Expand 'Save' and 'Print' dialogs as default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# DiskUtility: Show debug menu and advanced options
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

# Safari: Enable debug menu and developer options
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# App Store: Enable debug menus
defaults write com.apple.appstore WebKitDeveloperExtras -bool true
defaults write com.apple.appstore ShowDebugMenu -bool true

# Chrome: Allow extensions from Github and Userscripts
defaults write com.google.Chrome ExtensionInstallSources -array "https://*.github.com/*" "http://userscripts.org/*"

# Transmission: Trash .torrent file when adding, and hide warnings
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true
defaults write org.m0k.transmission WarningDonate -bool false
defaults write org.m0k.transmission WarningLegal -bool false




###############################################################################
# Roundup
###############################################################################
KILL_LIST=(Dashboard Dock Finder SystemUIServer)
for i in "${KILL_LIST[@]}"; do :
	killall $i
done
echo ''
echo ''
echo '***** DONE WITH OSX CONFIG *****'
echo ''
echo ''
