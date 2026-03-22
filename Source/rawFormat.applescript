(* *****************************************************************************

  rawFormat.scpt v1.0.1

  Copy the raw code from a selected item in Mail.app and paste it into TextEdit. This script will
 gives you the raw RFC/MIME message, not the already-decoded body that Mail renders
 for you.
  
 You will see the usually quoted-printable encoding with patterns like:
  
  =3D means the character =
  =0A means line feed
  =0D means carriage return  
  =20 means space
  
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