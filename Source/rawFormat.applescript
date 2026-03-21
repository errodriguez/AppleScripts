(* *****************************************************************************

  rawFormat.scpt v1.0.0

  Copy the raw code from a selected item in Mail.app and paste it into TextEdit.
  
  © Dr. Eduardo René Rodríguez Ávila, March 2026

***************************************************************************** *)

try
	tell application "Mail"
		activate
		
		set selectedMessages to selection
		if selectedMessages is {} then error "No email is selected in Mail.app."
		
		set theMessage to item 1 of selectedMessages
		
		try
			set rawSource to source of theMessage
		on error errMsg number errNum
			error "Could not read the raw source of the selected email. " & errMsg number errNum
		end try
	end tell
	
	tell application "TextEdit"
		activate
		make new document with properties {text:rawSource}
	end tell
	
on error errMsg number errNum
	display dialog errMsg buttons {"OK"} default button "OK" with icon stop
end try