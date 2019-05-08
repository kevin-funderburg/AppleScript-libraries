-- @description
-- Handlers for creating new Workflow script objects (mimics classes and constructors from OOP) to be used for developing Alfred 3 workflows
--
-- Authors: Ursan Razvan (original developer for Alfred 2, did most of the heavy lifting)
--          Kevin Funderburg - updates for Alfred 3 and extra handlers
--
-- Revised: 05/08/19 
--
--
use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"
use scripting additions

property name : "Alfred Library"
property id : "com.kfunderburg.library.alfredLibrary"
property version : "1.0.0"

property NSString : a reference to current application's NSString

property ICON_PATH_BASE : "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/"
property ICON_ERROR : {theType:"filepath", thePath:ICON_PATH_BASE & "AlertStopIcon.icns"}
property ICON_INFO : {theType:"filepath", thePath:ICON_PATH_BASE & "ToolbarInfo.icns"}

on newWorkflow()
	return my newWorkFlowWithBundle(missing value)
end newWorkflow


on newWorkFlowWithBundle(bundleid)
	script Workflow
		# the class name for AppleScript's internal use
		property class : "workflow"
		
		# class properties
		property _bundle : missing value
		property _cache : missing value
		property _data : missing value
		property _home : missing value
		property _localHash : missing value
		property _name : missing value
		property _path : missing value
		property _preferences : missing value
		property _results : missing value
		property _uuid : missing value
		
		on run
			set _bundle to (system attribute "alfred_workflow_bundleid")
			set _cache to (system attribute "alfred_workflow_cache")
			set _data to (system attribute "alfred_workflow_data")
			set _localHash to (system attribute "alfred_preferences_localhash")
			set _preferences to (system attribute "alfred_preferences")
			set _name to (system attribute "alfred_workflow_name")
			set _uuid to (system attribute "alfred_workflow_uid")
			set _version to (system attribute "alfred_version")
			set _versionBuild to (system attribute "alfred_version_build")
			
			# initialize the working folder
			set my _path to do shell script "pwd"
			if my _path does not end with "/" then set my _path to my _path & "/"
			
			# initialize the home folder
			set my _home to POSIX path of ((path to home folder) as alias)
			
			# create the path to the current Applescript's 'info.plist' file
			set _infoPlist to _path & "info.plist"
			
			# initialize the results list
			set my _results to {}
			
			# return this new script object
			return me
		end run
		
		on getPath()
			if my isEmpty(my _path) then return missing value
			
			return my _path
		end getPath
		
		on getHome()
			if my isEmpty(my _home) then return missing value
			
			return my _home
		end getHome
		on getResults()
			if my isEmpty(my _results) then return missing value
			
			return my _results
		end getResults
		on getUID()
			if my isEmpty(my _uuid) then return missing value
			
			return my _uuid
		end getUID
		on getName()
			if my isEmpty(my _name) then return missing value
			
			return my _name
		end getName
		on getPreferences()
			if my isEmpty(my _preferences) then return missing value
			
			return my _preferences
		end getPreferences
		on getBundleID()
			if my isEmpty(my _bundle) then return missing value
			
			return my _bundle
		end getBundleID
		on getData()
			if my isEmpty(my _data) then return missing value
			
			return _data
		end getData
		on getCache()
			if my isEmpty(my _cache) then return missing value
			
			return _cache
		end getCache
		on getVar(varName)
			if my isEmpty((system attribute varName)) then return missing value
			
			return (system attribute varName) as text
		end getVar
		
		on to_json(a)
			local r
			local json
			if (my q_is_empty(a)) and (not my q_is_empty(my _results)) then
				set a to my _results
			else if (my q_is_empty(a)) and (my q_is_empty(my _results)) then
				return missing value
			end if
			
			set tab2 to tab & tab
			set tab3 to tab & tab & tab
			set tab4 to tab & tab & tab & tab
			
			set json to "{\"items\": [" & return & return
			repeat with itemRef in a
				set r to contents of itemRef
				set json to json & tab & "{" & return
				if not q_is_empty(theUid of r) then
					set json to json & tab2 & "\"uid\": \"" & encode(theUid of r) & "\"," & return
				end if
				set json to json & tab2 & "\"valid\": \"" & my encode(isValid of r) & "\"," & return
				set json to json & tab2 & "\"title\": \"" & my encode(theTitle of r) & "\"," & return
				set json to json & tab2 & "\"subtitle\": \"" & my encode(theSubtitle of r) & "\"," & return
				set json to json & tab2 & "\"arg\": \"" & my encode(theArg of r) & "\"," & return
				if not q_is_empty(theAutocomplete of r) then
					set json to json & tab2 & "\"autocomplete\": \"" & my encode(theAutocomplete of r) & "\"," & return
				end if
				if not q_is_empty(theQuicklook of r) then
					set json to json & tab2 & "\"quicklookurl\": \"" & my encode(theQuicklook of r) & "\"," & return
				end if
				
				if not q_is_empty(theIcon of r) then
					set ic to theIcon of r
					set json to json & tab2 & "\"icon\": {" & return
					if not q_is_empty(theType of ic) then
						set json to json & tab3 & "\"type\": \"" & my encode(theType of ic) & "\"," & return
					end if
					if not q_is_empty(thePath of ic) then
						set json to json & tab3 & "\"path\": \"" & my encode(thePath of ic) & "\"" & return
					end if
					set json to json & tab2 & "}," & return
				end if
				
				if not q_is_empty(theVars of r) then
					set vars to ""
					set json to json & tab2 & "\"variables\" : {" & return
					repeat with v in theVars of r
						set varName to |name| of v
						set varVal to value of v
						set json to json & tab3 & "\"" & my encode(varName) & "\": \"" & my encode(varVal) & "\"," & return
					end repeat
					set json to json & tab2 & "}," & return
				end if
				
				if not q_is_empty(theMods of r) then
					set json to json & tab2 & "\"mods\": {" & return
					set m to theMods of r
					if not q_is_empty(cmd of m) then
						set json to json & tab3 & "\"cmd\": {" & return
						set json to json & tab4 & "\"valid\": \"" & my encode(isValid of cmd of m) & "\"," & return
						set json to json & tab4 & "\"arg\": \"" & my encode(theArg of cmd of m) & "\"," & return
						set json to json & tab4 & "\"subtitle\": \"" & my encode(theSubtitle of cmd of m) & "\"" & return
						set json to json & tab3 & "}," & return
					end if
					if not q_is_empty(alt of m) then
						set json to json & tab3 & "\"alt\": {" & return
						set json to json & tab4 & "\"valid\": \"" & my encode(isValid of alt of m) & "\"," & return
						set json to json & tab4 & "\"arg\": \"" & my encode(theArg of alt of m) & "\"," & return
						set json to json & tab4 & "\"subtitle\": \"" & my encode(theSubtitle of alt of m) & "\"" & return
						set json to json & tab3 & "}," & return
					end if
					if not q_is_empty(ctrl of m) then
						set json to json & tab3 & "\"ctrl\": {" & return
						set json to json & tab4 & "\"valid\": \"" & my encode(isValid of ctrl of m) & "\"," & return
						set json to json & tab4 & "\"arg\": \"" & my encode(theArg of ctrl of m) & "\"," & return
						set json to json & tab4 & "\"subtitle\": \"" & my encode(theSubtitle of ctrl of m) & "\"" & return
						set json to json & tab3 & "}," & return
					end if
					if not q_is_empty(shift of m) then
						set json to json & tab3 & "\"shift\": {" & return
						set json to json & tab4 & "\"valid\": \"" & my encode(isValid of shift of m) & "\"," & return
						set json to json & tab4 & "\"arg\": \"" & my encode(theArg of shift of m) & "\"," & return
						set json to json & tab4 & "\"subtitle\": \"" & my encode(theSubtitle of shift of m) & "\"" & return
						set json to json & tab3 & "}," & return
					end if
					if not q_is_empty(fn of m) then
						set json to json & tab3 & "\"fn\": {" & return
						set json to json & tab4 & "\"valid\": \"" & my encode(isValid of fn of m) & "\"," & return
						set json to json & tab4 & "\"arg\": \"" & my encode(theArg of fn of m) & "\"," & return
						set json to json & tab4 & "\"subtitle\": \"" & my encode(theSubtitle of fn of m) & "\"" & return
						set json to json & tab3 & "}," & return
					end if
					set json to json & tab2 & "}" & return
				end if
				
				if not q_is_empty(theText of r) then
					set json to json & tab2 & "\"text\": {" & return
					set t to theText of r
					if not q_is_empty(theCopy of t) then
						set json to json & tab3 & "\"copy\": \"" & my encode(theCopy of t) & "\"," & return
					end if
					if not q_is_empty(theLarge of t) then
						set json to json & tab3 & "\"largetype\": \"" & my encode(theLarge of t) & "\"" & return
					end if
					set json to json & tab2 & "}," & return
				end if
				
				set json to json & tab & "}," & return & return
				
			end repeat
			
			set json to json & return & "]}"
		end to_json
		
		
		-- @description
		-- gets the path of an application icon
		--
		-- @param $theApp - list of app names
		--
		on getIconPath(theApp)
			tell application "Finder" to set appnames to displayed name of every file in folder ((path to applications folder))
			--repeat with a in theApps
			
			if theApp = "Finder" then
				set iconrecord to {theType:"fileicon", thePath:"/System/Library/CoreServices/Finder.app"}
			else if theApp = "Global" then
				set iconrecord to {theType:"file", thePath:my getPreferences() & "/resources/GlobalAppIcon.icns"}
			else if theApp = "Script Editor" then
				set iconrecord to {theType:"fileicon", thePath:"/Applications/Utilities/Script Editor.app"}
			else if appnames contains theApp then
				set iconrecord to {theType:"fileicon", thePath:"/Applications/" & theApp & ".app"}
			else
				set iconrecord to {theType:"file", thePath:(my getPreferences() & "/resources/BlankAppIcon.png")}
			end if
		end getIconPath
		
		
		-- @description
		-- Helper function that just makes it easier to pass values into a function
		-- and create an array result to be passed back to Alfred
		--
		-- @param $theUid - the uid of the result, should be unique
		-- @param $theArg - the argument that will be passed on
		-- @param $theTitle - The title of the result item
		-- @param $theSubtitle - The subtitle text for the result item
		-- @param $theIcon - the icon to use for the result item
		-- @param $isValid - sets whether the result item can be actioned
		-- @param $theAutocomplete - the autocomplete value for the result item
		-- @param $theText - {theCopy:_copy, theLarge:_largetype}
		-- @return list items to be passed back to Alfred
		--
		on add_result given theUid:_uid, theArg:_arg, theTitle:_title, theSubtitle:_sub, theIcon:_icon, theAutocomplete:_auto, theType:_type, isValid:_valid, theQuicklook:_quicklook, theVars:_vars, theMods:_mods, theText:_text
			if _uid is missing value then set _uid to ""
			if _arg is missing value then set _arg to ""
			if _title is missing value then set _title to ""
			if _sub is missing value then set _sub to ""
			if _icon is missing value then set _icon to ""
			if _auto is missing value then set _auto to ""
			if _type is missing value then set _type to ""
			if _valid is missing value then set _valid to "yes"
			
			set temp to {theUid:_uid, theArg:_arg, theTitle:_title, theSubtitle:_sub, theIcon:_icon, theAutocomplete:_auto, theType:_type, isValid:_valid, theQuicklook:_quicklook, theVars:_vars, theMods:_mods, theText:_text}
			if my q_is_empty(_type) then
				set temp's theType to missing value
			end if
			
			set end of (my _results) to temp
			return temp
		end add_result
		
	end script
	
	tell Workflow to run
	# run the 'constructor' and return the new Workflow script object
	--return run script Workflow with parameters {""}
end newWorkFlowWithBundle


on isEmpty(str)
	if str is missing value then return true
	return length of (my q_trim(str)) is 0
end isEmpty

on q_join(l, delim)
	if class of l is not list or l is missing value then return ""
	repeat with i from 1 to length of l
		if item i of l is missing value then
			set item i of l to ""
		end if
	end repeat
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set output to l as text
	set AppleScript's text item delimiters to oldDelims
	return output
end q_join
on q_split(s, delim)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set output to text items of s
	set AppleScript's text item delimiters to oldDelims
	return output
end q_split
on q_file_exists(theFile)
	if my q_path_exists(theFile) then
		tell application "System Events"
			return (class of (disk item theFile) is file)
		end tell
	end if
	return false
end q_file_exists
on q_folder_exists(theFolder)
	if my q_path_exists(theFolder) then
		tell application "System Events"
			return (class of (disk item theFolder) is folder)
		end tell
	end if
	return false
end q_folder_exists
on q_path_exists(thePath)
	if thePath is missing value or my q_is_empty(thePath) then return false
	try
		if class of thePath is alias then return true
		if thePath contains ":" then
			alias thePath
			return true
		else if thePath contains "/" then
			POSIX file thePath as alias
			return true
		else
			return false
		end if
	on error msg
		return false
	end try
end q_path_exists
on q_is_empty(str)
	if str is missing value then return true
	return length of (my q_trim(str)) is 0
end q_is_empty
on q_trim(str)
	if class of str is not text or class of str is not string or str is missing value then return str
	if str is "" then return str
	repeat while str begins with " "
		try
			set str to items 2 thru -1 of str as text
		on error msg
			return ""
		end try
	end repeat
	repeat while str ends with " "
		try
			set str to items 1 thru -2 of str as text
		on error
			return ""
		end try
	end repeat
	return str
end q_trim
on q_clean_list(lst)
	if lst is missing value or class of lst is not list then return lst
	set l to {}
	repeat with lRef in lst
		set i to contents of lRef
		if i is not missing value then
			if class of i is not list then
				set end of l to i
			else if class of i is list then
				set end of l to my q_clean_list(i)
			end if
		end if
	end repeat
	return l
end q_clean_list
on q_encode(str)
	if class of str is not text or my q_is_empty(str) then return str
	set s to ""
	repeat with sRef in str
		set c to contents of sRef
		if c is in {"&", "'", "\"", "<", ">", tab} then
			if c is "&" then
				set s to s & "&amp;"
			else if c is "'" then
				set s to s & "&apos;"
			else if c is "\"" then
				set s to s & "&quot;"
			else if c is "<" then
				set s to s & "&lt;"
			else if c is ">" then
				set s to s & "&gt;"
			else if c is tab then
				set s to s & "&#009;"
			end if
		else
			set s to s & c
		end if
	end repeat
	return s
end q_encode
on q_date_to_unixdate(theDate)
	set {day:d, year:y, time:t} to theDate
	copy theDate to b
	set b's month to January
	set m to (b - 2500000 - theDate) div -2500000
	tell (y * 10000 + m * 100 + d) as text
		set UnixDate to text 5 thru 6 & "/" & text 7 thru 8 & "/" & text 1 thru 4
	end tell
	set h24 to t div hours
	set h12 to (h24 + 11) mod 12 + 1
	if (h12 = h24) then
		set ampm to " AM"
	else
		set ampm to " PM"
	end if
	set min to t mod hours div minutes
	set s to t mod minutes
	tell (1000000 + h12 * 10000 + min * 100 + s) as text
		set UnixTime to text 2 thru 3 & ":" & text 4 thru 5 & ":" & text 6 thru 7 & ampm
	end tell
	return UnixDate & " " & UnixTime
end q_date_to_unixdate
on q_unixdate_to_date(theUnixDate)
	return date theUnixDate
end q_unixdate_to_date
on q_timestamp_to_date(timestamp)
	if length of timestamp = 13 then
		set timestamp to characters 1 thru -4 of timestamp as text
	end if
	set h to do shell script "date -r " & timestamp & " \"+%Y %m %d %H %M %S\""
	set mydate to current date
	set year of mydate to (word 1 of h as integer)
	set month of mydate to (word 2 of h as integer)
	set day of mydate to (word 3 of h as integer)
	set hours of mydate to (word 4 of h as integer)
	set minutes of mydate to (word 5 of h as integer)
	set seconds of mydate to (word 6 of h as integer)
	return mydate
end q_timestamp_to_date
on q_date_to_timestamp(theDate)
	return ((current date) - (date ("1/1/1970")) - (time to GMT)) as miles as text
end q_date_to_timestamp
on q_send_notification(theMessage, theDetails, theExtra)
	set _path to do shell script "pwd"
	if _path does not end with "/" then set _path to _path & "/"
	if theMessage is missing value then set theMessage to ""
	if theDetails is missing value then set theDetails to ""
	if theExtra is missing value then set theExtra to ""
	if my q_trim(theMessage) is "" and my q_trim(theExtra) is "" then set theMessage to "notification"
	try
		do shell script (quoted form of _path & "bin/q_notifier.helper com.runningwithcrayons.Alfred-2 " & quoted form of theMessage & " " & quoted form of theDetails & " " & quoted form of theExtra)
	end try
end q_send_notification
on q_notify()
	my q_send_notification("", "", "")
end q_notify
on q_encode_url(str)
	local str
	try
		return (do shell script "/bin/echo " & quoted form of str & ¬
			" | perl -MURI::Escape -lne 'print uri_escape($_)'")
	on error
		return missing value
	end try
end q_encode_url
on q_decode_url(str)
	local str
	try
		return (do shell script "/bin/echo " & quoted form of str & ¬
			" | perl -MURI::Escape -lne 'print uri_unescape($_)'")
	on error
		return missing value
	end try
end q_decode_url

on SearchandReplace(sourceText, replaceThis, withThat)
	set theString to NSString's stringWithString:sourceText
	set theString to theString's stringByReplacingOccurrencesOfString:replaceThis withString:withThat
	return theString as text
end SearchandReplace

on SearchWithRegEx(thePattern, theString, n)
	set theNSString to NSString's stringWithString:theString
	set theOptions to ((current application's NSRegularExpressionDotMatchesLineSeparators) as integer) + ((current application's NSRegularExpressionAnchorsMatchLines) as integer)
	set theRegEx to current application's NSRegularExpression's regularExpressionWithPattern:thePattern options:theOptions |error|:(missing value)
	set theFinds to theRegEx's matchesInString:theNSString options:0 range:{location:0, |length|:theNSString's |length|()}
	set theResult to {} -- we will add to this
	repeat with i from 1 to count of items of theFinds
		set oneFind to (item i of theFinds)
		if (oneFind's numberOfRanges()) as integer < (n + 1) then
			set end of theResult to missing value
		else
			set theRange to (oneFind's rangeAtIndex:n)
			set end of theResult to (theNSString's substringWithRange:theRange) as string
		end if
	end repeat
	return theResult
end SearchWithRegEx

on readPlistAt:thePath
	set thePath to current application's NSString's stringWithString:thePath
	set thePath to thePath's stringByExpandingTildeInPath()
	set theDict to current application's NSDictionary's dictionaryWithContentsOfFile:thePath
	return theDict as record
end readPlistAt:



on encode(theString)
	if class of theString is not text then return theString
	if theString contains "\"" then set theString to my SearchandReplace(theString, "\"", "\\\"")
	--if theString contains "\\" then set theString to my SearchandReplace(theString, "\\", "\\\\")
	return theString
end encode


