on run argv
	set volName to item 1 of argv
	set installerName to item 2 of argv
	set guideName to item 3 of argv
	set settingsName to item 4 of argv

	tell application "Finder"
		tell disk volName
			open
			set theWindow to container window
			set current view of theWindow to icon view
			set toolbar visible of theWindow to false
			set statusbar visible of theWindow to false
			set bounds of theWindow to {120, 100, 640, 400}

			set viewOptions to the icon view options of theWindow
			set arrangement of viewOptions to not arranged
			set icon size of viewOptions to 88
			set text size of viewOptions to 11

			set position of item installerName to {120, 130}
			try
				set position of item guideName to {280, 130}
			end try
			try
				set position of item settingsName to {440, 130}
			end try

			close
			open
			update without registering applications
			delay 1
		end tell
	end tell
end run
