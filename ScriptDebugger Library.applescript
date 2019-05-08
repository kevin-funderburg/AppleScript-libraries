(*
--===============================================================================

Name:				ScriptDebugger Library
Description:		This library provides several useful editor functions for ScriptDebugger
Author:			Kevin Funderburg
Revised: 			10/19/18
Version: 			1.0
--===============================================================================
*)
use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

property name : "ScriptDebugger Library"
property id : "com.kfunderburg.library.scriptDebuggerLibrary"
property version : "1.0.0"

property sourceText : missing value
property theSelection : missing value
property theLocation : missing value
property theRange : missing value
property endOfSelection : missing value
property n : missing value
property post : missing value
property pre : missing value

on run
	tell application "Script Debugger"
		tell front document
			set {theLocation, theRange} to (get character range of selection)
			set sourceText to source text
			set endOfSelection to theLocation + theRange
			
			set n to 0
			set post to ""
			set pre to ""
		end tell
	end tell
end run

-- @description
-- Selects, copies, cuts, deletes current line
-- @params: "select", "copy", "cut", "delete"
--
on lineAction(action)
	set delims to return & linefeed
	tell me to run
	tell application "Script Debugger"
		tell front document
			repeat
				considering case
					if post = "" then
						set forward to character (endOfSelection + n) of sourceText
						if forward is in delims then
							set post to n
							if n = 0 then set n to n + 1
						end if
					end if
					if pre = "" then
						set backward to character (endOfSelection - n) of sourceText
						if backward is in delims then set pre to n - 1
					end if
					if post ≠ "" and pre ≠ "" then exit repeat
					set n to n + 1
				end considering
			end repeat
			
			set theLocation to endOfSelection - (pre)
			set theRange to pre + post
			set theSelection to {theLocation, theRange}
			
			if action = "select" then
				set selection to theSelection
				
			else if action contains "copy" or action contains "cut" then
				set the clipboard to characters theLocation thru (theLocation + theRange - 1) of sourceText as string
				if action contains "copy" then
					display notification (the clipboard) with title "Copied"
				else
					set action to "delete"
				end if
			end if
			
			if action contains "delete" then
				set selection to {theLocation, theRange + 1}
				set selection to ""
			end if
			
		end tell
	end tell
	
end lineAction

-- @description
-- Moves a line up or down
-- @params: "up", "down"
--
on moveLine(direction)
	set delims to return & linefeed
	tell me to run
	tell application "Script Debugger"
		tell front document
			set firstPara to ""
			repeat
				considering case
					
					if post = "" then
						set forward to character (endOfSelection + n) of sourceText
						if forward is in delims then
							if direction is "down" then
								if firstPara is "" then
									set firstPara to n
								else
									set post to n
									if n = 0 then set n to n + 1
								end if
							else
								set post to n
								if n = 0 then set n to n + 1
							end if
						end if
					end if
					
					if pre = "" then
						set backward to character (endOfSelection - n) of sourceText
						if backward is in delims then
							if direction is "down" then
								if n ≠ 0 then set pre to n - 1
							else
								if firstPara is "" then
									set firstPara to n
								else
									set pre to n - 1
								end if
							end if
						end if
					end if
					
					if post ≠ "" and pre ≠ "" then exit repeat
					set n to n + 1
				end considering
			end repeat
			
			set theLocation to endOfSelection - (pre)
			set theRange to pre + post
			set selection to {theLocation, theRange}
			
			set sel to selection
			set p1 to paragraph 1 of sel
			set p2 to paragraph 2 of sel
			set selection to p2 & return & p1
			
			if direction is "up" then
				set {theLocation, theRange} to (get character range of selection)
				set selection to {theLocation - ((length of p1) + 1), 0}
			end if
			
		end tell
	end tell
end moveLine

-- @description
-- Selects, copies, cuts, deletes word under cursor
-- @params: "select", "copy", "cut", "delete"
--
on wordAction(action)
	set delims to " :{},()\"" & return & tab & linefeed
	tell me to run
	tell application "Script Debugger"
		tell front document
			repeat
				considering case
					if post = "" then
						set forward to character (endOfSelection + n) of sourceText
						if forward is in delims then set post to n
					end if
					if pre = "" then
						set backward to character (endOfSelection - n) of sourceText
						if backward is in delims then
							if n > 0 then set pre to n - 1
						end if
					end if
					if post ≠ "" and pre ≠ "" then exit repeat
					set n to n + 1
				end considering
			end repeat
			
			set theLocation to endOfSelection - pre
			set theRange to pre + post
			set theSelection to {theLocation, theRange}
			
			if action = "select" then
				set selection to theSelection
				
			else if action contains "copy" or action contains "cut" then
				set the clipboard to characters theLocation thru (theLocation + theRange - 1) of sourceText as string
				if action contains "copy" then
					display notification (the clipboard) with title "Copied"
				else
					set action to "delete"
				end if
			end if
			
			if action contains "delete" then
				set selection to {theLocation, theRange}
				set selection to ""
			end if
			
		end tell
	end tell
end wordAction

-- @description
-- Selects, copies, cuts, deletes words in camelHumps mode
-- @params: "delete to word end", "delete to word start", "move cursor to next word", 
--          "move cursor to next word with selection", "move cursor to previous word",
--			  "move cursor to previous word with selection"
--
on camelCaseMode(action)
	set delims to " :{},()." & tab & return & linefeed
	set caps to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set invisibles to space & tab & return & linefeed
	
	tell me to run
	tell application "Script Debugger"
		tell front document
			
			if action contains "delete to word end" then
				repeat
					set char to character (endOfSelection + n) of sourceText
					if n ≠ 0 then
						considering case
							if char is in caps or char is in delims then exit repeat
						end considering
					end if
					set n to n + 1
				end repeat
				
				set selection to {theLocation, theRange + n}
				set selection to ""
				
			else if action contains "delete to word start" then
				
				repeat
					set char to character (theLocation - n) of sourceText
					if n > 1 then
						considering case
							if char is in caps or char is in delims then
								if char is in delims then set n to n - 1
								exit repeat
							end if
						end considering
					end if
					set n to n + 1
				end repeat
				
				set selection to {theLocation - n, theRange + n}
				set selection to ""
				
			else if action is "move cursor to next word" then
				
				repeat
					set char to character (theLocation + n) of sourceText
					if n ≠ 0 then
						considering case
							if char is in caps or char is in delims then exit repeat
						end considering
					end if
					set n to n + 1
				end repeat
				
				set selection to {theLocation + n, 0}
				
			else if action is "move cursor to next word with selection" then
				
				repeat
					set char to character (endOfSelection + n) of sourceText
					if n ≠ 0 then
						considering case
							if char is in caps or char is in delims then exit repeat
						end considering
					end if
					set n to n + 1
				end repeat
				
				set selection to {theLocation, theRange + n}
				
			else if action is "move cursor to previous word" then
				
				repeat
					set char to character (theLocation - n) of sourceText
					if n > 1 then
						considering case
							if char is in caps then
								exit repeat
							else if char is in delims then
								exit repeat
								set n to n - 1
							else if char is in invisibles then
								if character (theLocation - (n - 1)) of sourceText is not tab then
									set n to n - 1
									exit repeat
								end if
							end if
						end considering
					end if
					set n to n + 1
				end repeat
				
				set selection to {theLocation - n, 0}
				
			else if action is "move cursor to previous word with selection" then
				
				repeat
					set char to character (theLocation - n) of sourceText
					if n > 1 then
						considering case
							if char is in caps then
								exit repeat
							else if char is in delims then
								if character (theLocation - (n - 1)) of sourceText is tab then
									-- do nothing
								else
									set n to n - 1
									exit repeat
								end if
							else if char is in invisibles then
								if character (theLocation - (n - 1)) of sourceText is not tab then
									set n to n - 1
									exit repeat
								end if
							end if
						end considering
					end if
					set n to n + 1
				end repeat
				
				set selection to {theLocation - n, theRange + n}
				
			end if
		end tell
	end tell
end camelCaseMode