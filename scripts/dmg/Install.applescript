property dialogTitle : "__DIALOG_TITLE__"
property dialogBody : "__DIALOG_BODY__"
property openSettingsButton : "__OPEN_SETTINGS_BUTTON__"
property dismissButton : "__DISMISS_BUTTON__"
property settingsURL : "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension"

on openPrivacySettings()
	do shell script "open " & quoted form of settingsURL
end openPrivacySettings

on run
	set bundleRoot to POSIX path of (path to me)
	if bundleRoot ends with "/" then
		set bundleRoot to text 1 thru -2 of bundleRoot
	end if
	set sourceApp to bundleRoot & "/Contents/Resources/AttentionClock.app"
	set destApp to "/Applications/AttentionClock.app"

	try
		do shell script "test -d " & quoted form of sourceApp
	on error
		display dialog dialogBody & return & return & "(Missing app bundle in installer.)" with title dialogTitle buttons {dismissButton} default button 1 with icon stop
		return
	end try

	try
		do shell script "ditto " & quoted form of sourceApp & " " & quoted form of destApp
	on error errMsg number errNum
		display dialog dialogBody & return & return & ("(" & errNum & ") " & errMsg) with title dialogTitle buttons {dismissButton} default button 1 with icon stop
		return
	end try

	try
		do shell script "open " & quoted form of destApp
	end try

	set userChoice to button returned of (display dialog dialogBody with title dialogTitle buttons {openSettingsButton, dismissButton} default button 1 with icon note giving up after 90)
	if userChoice is openSettingsButton then
		my openPrivacySettings()
	end if
end run
