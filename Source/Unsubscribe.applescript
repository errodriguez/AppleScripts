(* *****************************************************************************

  Unsubscribe.scpt v1.1.2

  Copy the email destination address from an email, and look for a link to unsubscribe. If a link is
 found, open Safari with it. If necessary, the email is in the clipboard, ready to
 paste. 
  
  © Dr. Eduardo René Rodríguez Ávila, March 2026


Some known issues still to be addressed: 

- With some e-mail accounts or services (at this time, being only aware of Yahoo!), two or more
  email addresses or mailboxes can be linked, and this is detected as two or more emails selected,
 despite there is only one selected in the Mail app.
 
- The script doesn't recognise selected items in smart mailboxes.

- Some emails use images entirely; you can see text, but they are just images.
***************************************************************************** *)

use AppleScript version "2.7"
use framework "Foundation"
use scripting additions

tell application "Mail"
	set selectedMessages to selection
	if (count of selectedMessages) is less than 1 then
		display dialog "Please select one email message in Mail." buttons {"OK"} default button "OK" with icon caution
		return
	end if
	
	if (count of selectedMessages) is not 1 then
		display dialog "Please select exactly one email message in Mail." buttons {"OK"} default button "OK" with icon caution
		return
	end if
	
	set theMessage to item 1 of selectedMessages
	
	-- Get the receiver address (first address in To:)
	set receiverAddress to my firstToAddressFromMessage(theMessage)
	if receiverAddress is missing value or receiverAddress is "" then
		display dialog "Could not determine the receiver email address from the selected message." buttons {"OK"} default button "OK" with icon caution
		return
	end if
	
	set the clipboard to receiverAddress
	
	-- Get raw source and normalize some common quoted-printable artifacts
	set rawSource to source of theMessage
end tell

set normalizedSource to my normalizeMessageSource(rawSource)

set unsubscribeURL to my findUnsubscribeURL(normalizedSource)

if unsubscribeURL is missing value or unsubscribeURL is "" then
	display dialog "No unsubscribe link was found in the selected message." buttons {"OK"} default button "OK" with icon caution
	return
end if

set unsubscribeURL to my basicHTMLDecode(unsubscribeURL)

-- Open Safari with the extracted URL
tell application "Safari"
	activate
	if (count of windows) = 0 then
		make new document with properties {URL:unsubscribeURL}
	else
		set URL of front document to unsubscribeURL
	end if
end tell


on firstToAddressFromMessage(theMessage)
	tell application "Mail"
		try
			set theRecipients to to recipients of theMessage
			repeat with r in theRecipients
				try
					set a to address of r
					if a is not missing value and a is not "" then return a
				end try
			end repeat
		end try
		
		try
			set rawSource to source of theMessage
		on error
			return missing value
		end try
	end tell
	
	set unfoldedHeaders to my unfoldRFCHeaders(rawSource)
	
	set headerValue to my firstCaptureGroup(unfoldedHeaders, "(?im)^To:\\s*(.+)$", 1)
	if headerValue is not missing value then
		set parsedEmail to my firstEmailAddressInText(headerValue)
		if parsedEmail is not missing value then return parsedEmail
	end if
	
	set headerValue to my firstCaptureGroup(unfoldedHeaders, "(?im)^Delivered-To:\\s*(.+)$", 1)
	if headerValue is not missing value then
		set parsedEmail to my firstEmailAddressInText(headerValue)
		if parsedEmail is not missing value then return parsedEmail
	end if
	
	set headerValue to my firstCaptureGroup(unfoldedHeaders, "(?im)^X-Original-To:\\s*(.+)$", 1)
	if headerValue is not missing value then
		set parsedEmail to my firstEmailAddressInText(headerValue)
		if parsedEmail is not missing value then return parsedEmail
	end if
	
	return missing value
end firstToAddressFromMessage

on unfoldRFCHeaders(theText)
	set s to current application's NSString's stringWithString:theText
	set s to s's stringByReplacingOccurrencesOfString:("
" & tab) withString:" "
	set s to s's stringByReplacingOccurrencesOfString:("
 ") withString:" "
	set s to s's stringByReplacingOccurrencesOfString:("
" & tab) withString:" "
	set s to s's stringByReplacingOccurrencesOfString:("
 ") withString:" "
	return (s as text)
end unfoldRFCHeaders

on normalizeMessageSource(theText)
	set s to current application's NSString's stringWithString:theText
	
	set s to s's stringByReplacingOccurrencesOfString:("=
") withString:""
	set s to s's stringByReplacingOccurrencesOfString:("=
") withString:""
	set s to s's stringByReplacingOccurrencesOfString:("=
") withString:""
	
	set s to s's stringByReplacingOccurrencesOfString:"=3D" withString:"=" options:(current application's NSCaseInsensitiveSearch) range:{location:0, |length|:s's |length|()}
	
	return (s as text)
end normalizeMessageSource

on findUnsubscribeURL(theText)
	-- Case 1: keyword is in the <a> attributes or inside the <a> text
	set hrefValue to my firstCaptureGroup(theText, "(?is)<a\\b(?=[^>]*\\b(?:unsubscribe|desuscribirse|desubscribirse)\\b|[^>]*>(?:(?!</a>).)*?\\b(?:unsubscribe|desuscribirse|desubscribirse)\\b)[^>]*\\bhref\\s*=\\s*(['\"])([^'\"<>]*)\\1[^>]*>(?:(?!</a>).)*?</a>", 2)
	if hrefValue is not missing value then return hrefValue
	
	-- Case 2: keyword is in surrounding text inside the same container, then an <a> appears
	set hrefValue to my firstCaptureGroup(theText, "(?is)<([a-z][a-z0-9]*)\\b[^>]*>(?:(?!</\\1>).)*?\\b(?:unsubscribe|desuscribirse|desubscribirse|aqu)\\b(?:(?!</\\1>).)*?<a\\b[^>]*\\bhref\\s*=\\s*(['\"])([^'\"<>]*)\\2[^>]*>(?:(?!</a>).)*?</a>(?:(?!</\\1>).)*?</\\1>", 3)
	if hrefValue is not missing value then return hrefValue
	
	return missing value
end findUnsubscribeURL

on firstEmailAddressInText(theText)
	return my firstCaptureGroup(theText, "(?i)([A-Z0-9._%+\\-]+@[A-Z0-9.\\-]+\\.[A-Z]{2,})", 1)
end firstEmailAddressInText

on basicHTMLDecode(theText)
	set s to current application's NSString's stringWithString:theText
	set s to s's stringByReplacingOccurrencesOfString:"&amp;" withString:"&"
	set s to s's stringByReplacingOccurrencesOfString:"&lt;" withString:"<"
	set s to s's stringByReplacingOccurrencesOfString:"&gt;" withString:">"
	set s to s's stringByReplacingOccurrencesOfString:"&quot;" withString:"\""
	set s to s's stringByReplacingOccurrencesOfString:"&#39;" withString:"'"
	return (s as text)
end basicHTMLDecode

on firstCaptureGroup(theText, thePattern, groupIndex)
	set nsText to current application's NSString's stringWithString:theText
	set fullRange to current application's NSMakeRange(0, nsText's |length|())
	
	set {theRegex, theError} to current application's NSRegularExpression's regularExpressionWithPattern:thePattern options:0 |error|:(reference)
	if theRegex is missing value then error ("Regex error: " & (theError's localizedDescription() as text))
	
	set theMatch to theRegex's firstMatchInString:nsText options:0 range:fullRange
	if theMatch is missing value then return missing value
	
	set capRange to (theMatch's rangeAtIndex:groupIndex) as record
	if (location of capRange) = current application's NSNotFound then return missing value
	
	return (nsText's substringWithRange:(current application's NSMakeRange((location of capRange), (|length| of capRange)))) as text
end firstCaptureGroup
