use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use framework "Foundation"

-- classes, constants, and enums used
property NSString : a reference to current application's NSString

property name : "Kevin's Scripting Library"
property id : "com.kfunderburg.library.kevinsScriptingLibrary"
property version : "1.0.0"

property cr : character id 13
property lf : character id 10
property vt : character id 11

(*
===============================================================================
              				TEXT UTILITIES HANDLERS
===============================================================================

Version: 1.0         							Updated: 10/31/2017 03:40 PM CST
By: Kevin Funderburg

PURPOSE:

Transform case of text, search/replace text in given string

VERSION HISTORY:
1.0 - Initial version.
===============================================================================
*)
--» Text Utilities
on transformText(inString, caseIndicator)
	-- create a Cocoa string from the passed text, by calling the NSString class method stringWithString:
	set the sourceString to NSString's stringWithString:inString
	-- apply the indicated transformation to the Cocoa string
	if the caseIndicator is "upper" then
		set the adjustedString to sourceString's uppercaseString()
	else if the caseIndicator is "lower" then
		set the adjustedString to sourceString's lowercaseString()
	else
		set the adjustedString to sourceString's capitalizedString()
	end if
	-- convert from Cocoa string to AppleScript text
	return (adjustedString as text)
end transformText


-- Capitalize the first word in a sentence
on capFirstWord(inString)
	set char1 to first character of inString
	set comparisonString to "abcdefghijklmnopqrstuvwxyz"
	if char1 is in comparisonString then set char1 to transformText(char1, "upper")
	set newText to (char1 & (characters 2 thru end of inString)) as string
	return newText
end capFirstWord


on split(theString, theSeparator)
	local saveTID, theResult
	
	set saveTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theSeparator
	set theResult to text items of theString
	set AppleScript's text item delimiters to saveTID
	return theResult
end split


on join(theString, theSeparator)
	local saveTID, theResult
	
	set saveTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theSeparator
	set theResult to theString as text
	set AppleScript's text item delimiters to saveTID
	return theResult
end join


on extractBetween(SearchText, startText, endText)
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to startText
	set endItems to text of text item -1 of SearchText
	set AppleScript's text item delimiters to endText
	set beginningToEnd to text of text item 1 of endItems
	set AppleScript's text item delimiters to tid
	return beginningToEnd
end extractBetween


on SearchandReplace(sourceText, replaceThis, withThat)
	set theString to NSString's stringWithString:sourceText
	set theString to theString's stringByReplacingOccurrencesOfString:replaceThis withString:withThat
	return theString as text
end SearchandReplace


on SearchWithRegEx(thePattern, theString, n)
	--on SearchWithRegEx:thePattern inString:theString capturing:n
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
	--end SearchWithRegEx:inString:capturing:
end SearchWithRegEx


on TrimWhitespace(sourceString)
	set aString to ((NSString's stringWithString:sourceString)'s stringByTrimmingCharactersInSet:(current application's NSCharacterSet's whitespaceAndNewlineCharacterSet())) as text
	return aString
end TrimWhitespace


on isEmpty(str)
	if str is missing value then return true
	return length of str is 0
end isEmpty
---——————————————————————————————————————————————-


on encodePosixtoHFS(theString)
	if theString contains "~" then set theString to my SearchandReplace(theString, "~", path to home folder as string)
	if theString starts with "/Users" then set theString to "Macintosh HD" & theString
	if theString contains "\\" then set theString to my SearchandReplace(theString, "\\", "")
	if theString contains "\"" then set theString to my SearchandReplace(theString, "\"", "")
	return my SearchandReplace(theString, "/", ":")
end encodePosixtoHFS


on encodeHFStoPosix(theString)
	if theString contains "~/" then set theString to my SearchandReplace(theString, (path to home folder as string), "~/")
	return my SearchandReplace(theString, ":", "/")
end encodeHFStoPosix


on escBshPth(theString)
	set theString to SearchandReplace(theString, " ", "\\ ")
	set theString to SearchandReplace(theString, ")", "\\) ")
	set theString to SearchandReplace(theString, "(", "\\( ")
	return theString
end escBshPth

--===============================================================================


(*
===============================================================================
              				SAFARI CONTROL HANDLERS
===============================================================================

Version: 1.0         							Updated: 10/31/2017 03:40 PM CST
By: Kevin Funderburg

PURPOSE:

Click links, input text into Safari fields

VERSION HISTORY:
1.0 - Initial version.
===============================================================================
*)
--» Browser Control

-- @Description
-- Performs basic JavaScript actions in Safari
-- @param - theAction: get, set, click, submit
-- @param - theType: id, class, etc
-- @param - id: the string associated with the object
-- @param - num: the index of the object
-- @param - theValue: value an object is to be set to (set to missing value by default)
-- @param - theTab: the tab the action is to be performed in
--
on doJava:theAction onType:theType withIdentifier:theID withElementNum:num withSetValue:theValue inTab:thetab
	if theType = "id" then
		set getBy to "getElementById"
		set theJavaEnd to ""
	else
		if theType = "class" then
			set theType to "ClassName"
		else if theType = "name" then
			set theType to "Name"
		else if theType = "tag" then
			set theType to "TagName"
		end if
		set getBy to "getElementsBy" & theType
		set theJavaEnd to "[" & num & "]"
	end if
	
	if theAction = "click" then
		set theJavaEnd to theJavaEnd & ".click();"
	else if theAction = "get" then
		set theJavaEnd to theJavaEnd & ".innerHTML;"
	else if theAction = "set" then
		set theJavaEnd to theJavaEnd & ".value ='" & theValue & "';"
	else if theAction = "submit" then
	else if theAction = "force" then
	end if
	
	set theJava to "document." & getBy & "('" & theID & "')" & theJavaEnd
	
	tell application "Safari"
		if thetab is missing value then set thetab to front document
		tell thetab
			if theAction = "get" then
				set input to do JavaScript theJava
				return input
			else
				do JavaScript theJava
			end if
		end tell
	end tell
	
end doJava:onType:withIdentifier:withElementNum:withSetValue:inTab:


###——————————————————————————————————————————————-
#			A tab is passed as a parameter in case you dont want it to come to the front
#
#			Ver 1.0				04/02/2018
###——————————————————————————————————————————————-
on waitForSafariToLoad(SearchText, thetab)
	set tabText to ""
	set failsafe to 0
	
	tell application "Safari"
		tell front window
			if thetab is missing value then set thetab to current tab
			
			repeat until tabText contains SearchText
				set tabText to text of thetab
				delay 0.1
				set failsafe to failsafe + 1
				if failsafe = 300 then
					error "Script timed out, Safari didn't load" number -100
				end if
			end repeat
			
		end tell
	end tell
end waitForSafariToLoad


on checkForExistingTab(theURLs)
	if class of theURLs is text then set theURLs to theURLs as list
	
	tell application "Safari"
		tell front window
			
			set URLs to URL of every tab
			set URLfound to false
			
			repeat with q from 1 to count of theURLs
				set theURL to item q of theURLs
				
				if URLs contains theURL then
					repeat with n from 1 to (count of URLs)
						if item n of URLs is theURL then
							set URLfound to true
							exit repeat
						end if
					end repeat
					set thetab to tab n
				end if
				
				if URLfound then exit repeat
			end repeat
			
			if URLfound is false then
				open location theURL
				set thetab to current tab
			end if
			
		end tell
	end tell
end checkForExistingTab


(*
===============================================================================
          							LIST HANDLERS
===============================================================================

Version: 1.0												Updated: 02/20/2018 10:00 CST
By: Kevin Funderburg

PURPOSE:

Common handlers for use with lists.


VERSION HISTORY:
1.0 - Initial version.
===============================================================================
*)
--» List Handlers
-- Used to return the offset of a searched item
on list_position(this_item, this_list)
	repeat with i from 1 to the count of this_list
		if item i of this_list is this_item then return i
	end repeat
	return 0
end list_position


-- Used to count how many times an item is in a specified list
on ls__countMatchesInList(this_list, this_item)
	set the match_counter to 0
	repeat with i from 1 to the count of this_list
		if item i of this_list contains this_item then ¬
			set the match_counter to the match_counter + 1
	end repeat
	return the match_counter
end ls__countMatchesInList


on ls__makeParasFromList(this_list)
	set textList to ""
	repeat with n from 1 to count of this_list
		if textList = "" then
			set textList to item n of this_list
		else
			set textList to textList & return & item n of this_list
		end if
	end repeat
	return textList
end ls__makeParasFromList


on sortAList:theList
	set theArray to current application's NSArray's arrayWithArray:theList
	set theArray to theArray's sortedArrayUsingSelector:"localizedStandardCompare:"
	return theArray as list
end sortAList:


--===============================================================================
--» File Handlers
on makeFileReference(theFile)
	--	Convert a string path into a file reference
	--
	--	Parameters:
	--
	--	theFile - when a string, can be a full HFS path, a full Posix Path (beginning with /), a HOME-relative Posix path (beginning with ~/)
	--			- when an alias, returned as is
	--			- when a file referene, returned as is
	--
	if class of theFile is string and character 1 of theFile is "/" then
		set theFile to POSIX file theFile
	else if class of theFile is string and character 1 of theFile is "~" then
		set theFile to POSIX file ((POSIX path of (path to home folder)) & text 2 thru -1 of theFile)
	else if class of theFile is string then
		set theFile to alias theFile
	end if
	
	return theFile
end makeFileReference


on readFromFileAs(theFile, theClass)
	try
		local fileReference, fileSpec
		if class of theFile is string and character 1 of theFile is "/" then
			set theFile to POSIX file theFile
		else if class of theFile is string and character 1 of theFile is "~" then
			set theFile to POSIX file ((POSIX path of (path to home folder)) & text 2 thru -1 of theFile)
		else if class of theFile is string then
			set theFile to alias theFile
		end if
		
		set fileReference to open for access theFile
		set theData to read fileReference as theClass
		close access fileReference
		return theData
	on error
		try
			close access file theFile
		end try
		return missing value
	end try
end readFromFileAs


on fileExists(theFile)
	log "checking for file"
	if my pathExists(theFile) then
		tell application "System Events"
			return (class of (disk item theFile) is file)
		end tell
	end if
	return false
end fileExists


on folderExists(theFolder)
	if my pathExists(theFolder) then
		tell application "System Events"
			return (class of (disk item theFolder) is folder)
		end tell
	end if
	return false
end folderExists


on pathExists(thePath)
	log "checking for path"
	if thePath is missing value or my isEmpty(thePath) then return false
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
end pathExists


on writeToFile(theFile, theData)
	--	Write theData to theFile (file ref or string path)
	try
		local fileReference, fileSpec
		
		set theFile to makeFileReference(theFile)
		set fileReference to open for access theFile with write permission
		set eof fileReference to 0
		write theData to fileReference as «class utf8»
		close access fileReference
		return theFile
	on error errMessage number errNum
		try
			close access file theFile
		end try
		error errMessage number errNum
	end try
	
end writeToFile


on readPlistAt:thePath
	set thePath to current application's NSString's stringWithString:thePath
	set thePath to thePath's stringByExpandingTildeInPath()
	set theDict to current application's NSDictionary's dictionaryWithContentsOfFile:thePath
	return theDict as record
end readPlistAt:


on getKeychainItem(keychainItemName)
	do shell script "security 2>&1 >/dev/null find-generic-password -gl " & quoted form of keychainItemName & " | awk '{print $2}'"
	if result is not "SecKeychainSearchCopyNext:" then return (text 2 thru -2 of result)
	return missing value
end getKeychainItem


on throwError(errMsg)
	error errMsg number 1000
end throwError

