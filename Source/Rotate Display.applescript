(* *****************************************************************************

   Rotate Displays.scpt v1.0.1

   Toggles between 0 and 270 degrees on a secondary display.

   © Dr. Eduardo René Rodríguez Ávila, May 2023

***************************************************************************** *)

tell application "System Settings" to quit
delay 1

do shell script "open x-apple.systempreferences:com.apple.preference.displays"

tell application "System Events"
	tell application process "System Settings"
		activate
		delay 2
		
		key code 48
		key code 48
		delay 1
		
		key code 49
		delay 1
		
		set theButton to pop up button "Rotation" of group 4 of scroll area 2 of group 1 of group 2 of splitter group 1 of group 1 of window "Displays" of application process "System Settings" of application "System Events"
		tell theButton
			set theRotation to the value of it
			click
			tell menu 1
				if theRotation is "270°" then
					click menu item 1
				else
					click menu item 4
				end if
			end tell
		end tell
	end tell
end tell

tell application "System Settings" to quit