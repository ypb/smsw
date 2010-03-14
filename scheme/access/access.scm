
;; -nv 
; (define wget-ftp-opts "--passive-ftp --tries=5 --wait=60 --random-wait --progress=dot:mega")
(define wget-ftp-opts '("--passive-ftp" "--tries=5" "--wait=60" "--random-wait"))

;; TODO urlify?... like "better", oh, the jumble of disabstraction...

(define (get-file local remote)
  (let ((proto (protocol)))
    (if proto
	(cond
	 ((eq? 'ftp proto)
	  (get-file-ftp local remote))
	 (else (begin (display "Uknown protocol: ")
		      (display proto)
		      (newline)
		      #f))))))

;;; erm... for now we assume remote-file-name = local-file-name
;; directory parts are of course different "only"... you dummie!
(define (get-file-ftp local remote)
  (display "ftp: ")
  (display local)
  (display " <- ")
  (display remote)
  (newline)
  (if (verify-directory SMSW_TMP)
      (let* ((file (file-name-nondirectory remote))
	     (url (string-append "ftp://" remote))
	     (options (let ((tmp (wget-opts)))
			(or tmp
			    wget-ftp-opts)))
	     (tmp (string-append SMSW_TMP "/" file)))
	(delete-filesys-object tmp)
	(let ((status (with-cwd SMSW_TMP
				(run (wget ,@options ,url)))))
	  (if (= status 0)
	      (begin (rename-file tmp
				  local)
		     (file-exists? local))
	      #f)))
      (begin (display "Trouble with temp dir: ")
	     (display SMSW_TMP)
	     (newline)
	     #f)))
