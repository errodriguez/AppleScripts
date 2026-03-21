(* *****************************************************************************

   PP2PNG.scpt v1.0.0

   Copy a selected image in MS PowerPoint to the Preview app and open the
  "Save As..." dialogue. The purpose of the script is to facilitate a workflow when
  you are editing images in Microsoft PowerPoint (for example, removing the 
  background of the images).

   © Dr. Eduardo René Rodríguez Ávila, March 2026

***************************************************************************** *)



tell application "Microsoft PowerPoint"
	activate
end tell

delay 0.5

tell application "System Events"
	tell process "Microsoft PowerPoint"
		-- Copiar imagen seleccionada
		keystroke "c" using command down
	end tell
end tell

delay 0.5

-- Abrir Preview
if application "Preview" is not running then
	tell application "Preview" to launch
end if

tell application "Preview" to activate

delay 0.5

tell application "System Events"
	tell process "Preview"
		
		-- Nuevo desde portapapeles
		keystroke "n" using command down
		
		delay 0.7
		
		-- Exportar
		keystroke "s" using {command down}
		
		delay 1
		
	end tell
end tell