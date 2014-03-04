cd "/Applications/Microsoft Office 2011/Microsoft Outlook.app/Contents/Resources/en.lproj"
plutil -convert xml1 OutlookMainWindow.nib
sed -i.bu 's/<key>NSWindowBacking<\/key>/<key>NSWindowCollectionBehavior<\/key><integer>128<\/integer><key>NSWindowBacking<\/key>/' OutlookMainWindow.nib
plutil -convert binary1 OutlookMainWindow.nib
