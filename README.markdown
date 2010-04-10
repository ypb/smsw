# ScheMeta SlackWarez
    "For every basement dweller there is Da7a of 9ines fjording from the Middle
      ground." -- Mr Stey "Reproduction is Death" O. Reginand

[Slackware](http://www.slackware.com/) Linux package manager written in
[Scsh](http://www.scsh.net/) - Unix schell embedded within
[Scheme](http://www.schemers.org/) - a dialect of Lisp.

## Installing

### Prerequisites:

  * slackware (duh!)
  * scsh
  * rlwrap (or any other readline-like CLI widget, perhaps even Emacs ;)

Edit top of Makefile to your liking, then 'make install' should do it...

## Features

Before you fire it up you probably want to edit&move the {config,mirror}.example.

Ener... I mean execute!
,in smsw
(start)

You can:

(status)					; mainly if you move-to'ed
						; for some weird reason
(move-to "other-version-than-in-config")	; bend space-time
; TODO include extra and patches handling
(list-pkg "fragname")
(find-pkg "exactname")				; without -V-A-B part
(list-pkgs "smth"...)				; i forget what it does...

(get-pkg "exactname")
(get-core-pkgs)					; 'REC in "a" "ap" "n" (iirc)

(list-installed)
(upgrade-hints)
(update-hints)

(list-lpkg "fragname")				; l as in "local"
(find-lpkg "exactname")

; poke at MANIFEST; for now you have to get&unpack it in SMSW_VAR
(smani-pkgs "posix-regexp") 	     		; list only package names containing
(smani-full "posix-regexp")			; plus full result of grep...ing

(help)	    					; call the doctor

; there is also rudimentary "logging" (wget "URL") if you 'mkdir -p SMSW_VAR/tdm/files'

[.](http://en.wikipedia.org/wiki/Markdown)
