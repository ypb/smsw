
(define SMSW_TMP (string-append SMSW_VAR "/tmp"))

; format ((var . value) ...)

(define (get-variable sym)
  (let ((cfg (get-main)))
    (if (not (null? cfg))
	(let ((tmp (assq sym cfg)))
	  (and tmp (cdr tmp)))
	#f)))

(define (set-variable sym val)
  (let ((cfg (get-main)))
    (if (not (null? cfg))
	(let ((tmp (assq sym cfg)))
	  (and tmp (set-cdr! tmp val)))
	#f)))

(define (switch-release num-str)
  (display "Switching release: -old(")
  (display (version))
  (display ") +new(")
  (set-variable 'current num-str)
  (display (version))
  (display ").")
  (newline))

; error on 'unbound or or or what? if config empty? hmmm...

; see config/etc.scm
(define local-version read-local-version)

; string
(define (slackware-version)
  (let ((tmp (get-variable 'current)))
    (and tmp
	 (string-append "slackware-"
			(if (number? tmp)
			    (number->string tmp)
			    tmp)))))
; symbol
(define (protocol)
  (get-variable 'access))
; string
(define (mirror-string)
  (get-variable 'mirror))
(define (mirror-strings)
  (get-variable 'mirrors))

;;;

; string only because number->string gets 13.0 crooked (i.e. "13.")
(define (version)
  (get-variable 'current))
; list of strings...
(define (wget-opts)
  (get-variable 'wget))
