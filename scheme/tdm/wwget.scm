
;;; TEH trivial download manager...

(define tdm-root-dir (string-append SMSW_VAR "/tdm"))
(define tdm-files-dir (string-append tdm-root-dir "/files"))
(define tdm-store-file (string-append tdm-root-dir "/tdm.store"))

(define tdm-bobs '())

; "BOBs" but object blobs...
; format (num . ("filename" . ("sourceN" ...)))

; for now we foresee that the same file can be located in many "url-places",
; but at the same time it's obviously painful that "filename" has no reason
; to be unique...

; top level actor
(define (tdm action . arg-list)
  (case action
    ((add) (apply tdm-add arg-list))
    (else (tdm-list))))

(define (tdm-list)
  (for-each (lambda (rec)
	      (display rec)
	      (newline))
	    tdm-bobs))

(define (tdm-add url)
  (let* ((bob (url->bob url))
	 (bub (bob-exists? bob)))
    (if bub
	bub
	; DWIM
	)))

;;; ermmm... let's start "slow"

(define wget-options '("--continue" "--passive-ftp" "--no-check-certificate"
		       "--server-response"
		       "--progress=dot:mega" "--timestamping"
		       "--tries=0" "--waitretry=60"))

;; TOINVESTIGATE: emacs' paren matching borkez on (|+ ...)

(define (wget url)
  (let* ((file-name (last ((infix-splitter (rx "/")) url)))
	 (log-to (string-append file-name ".tdm")))
    (let ((status (with-cwd tdm-files-dir
			    (run (|+ ((1 2 0))
				     (wget ,@wget-options ,url)
				     (tee -a ,log-to))))))
      (or (zero? status)
          status))))
; end is, qyoot, too...

;;; Q: what do we do with funny "? & % $" farms...
; (define (wget-to hint+url)) ;?
; 0. first gather log and search for 302 + Location: header...
; 1. ...
