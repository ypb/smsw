
(define SMSW_TMP (string-append SMSW_VAR "/tmp"))

; format ((var . value) ...)

(define (get-variable sym)
  (let ((cfg (get-main)))
    (if (not (null? cfg))
	(let ((tmp (assq sym cfg)))
	  (and tmp (cdr tmp)))
	#f)))

; error on 'unbound or or or what? if config empty? hmmm...

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

;;;

; string only because number->string gets 13.0 crooked (i.e. "13.")
(define (version)
  (get-variable 'current))
; list of strings...
(define (wget-opts)
  (get-variable 'wget))
