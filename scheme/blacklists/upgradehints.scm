
;; TODO add config options? if we should use those files...

;; known external packages i.e. ones installed by us from outside of main Slackware
; may be iffy in case of unforeseen future name collisions
; but the purpose is to find discontinued or newly introduced packages...

; used in determine-external
(define extefile (string-append SMSW_ETC "/filters/external"))
; used in upgrade-hints ignore those remote ADD names...
;; iffy, too, like hell, but what's not?
(define ignafile (string-append SMSW_ETC "/filters/ignoreadd"))

;; TODO add filtering out comments and SUCH

(define (just-read file)
  (if (not (and (file-exists? file)
		(file-readable? file)))
      (begin (display "Trouble with ")
	     (display file)
	     (display " file.")
	     (newline)
	     '())
      (with-input-from-file file
	(lambda ()
	  (let loop ((l (read-line)))
	    (if (not (eof-object? l))
		(cons l (loop (read-line)))
		'()))))))

(define (read-external)
  (just-read extefile))
(define (read-ignoreadd)
  (just-read ignafile))
