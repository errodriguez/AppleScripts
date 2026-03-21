(* *****************************************************************************

   Pull All Windows.scpt v1.0.1

   Move all windows to the main display.

   © Dr. Eduardo René Rodríguez Ávila, Oct. 2023

***************************************************************************** *)

(*

   This script is set for the case of a secondary display "above" the main one, as depicted:
   
                      +----------------------+ 2560x1080
                      |                              |
                      |                              |
                      +----------------------+
                         +--------------+ 1440x900
                         |                    |
                         |                    |
                         |                    |
                         +--------------+
						 
  Positive Y values for the main display, negative values for the secondary display. Adjust
 X, Y, width and  height variables as desired and accordingly						 
*)

-- Assuming main display is "below" of the secundary one.
set X to 200
set Y to 100

-- Resize all windows with an specific width and height. 
set width to 1000
set height to 800

use application "System Events"

get the name of every application process whose class of windows contains window

repeat with eachProcess in the result
	
	get (every window of process (contents of eachProcess) whose value of attribute "AXMinimized" is false)
	
	repeat with eachWindow in the result
		set position of eachWindow to {X, Y}
		set size of eachWindow to {width, height}
	end repeat
	
end repeat
