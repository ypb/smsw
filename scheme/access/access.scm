
;; -nv 
; (define wget-ftp-opts "--passive-ftp --tries=5 --wait=60 --random-wait --progress=dot:mega")
(define wget-ftp-opts '("--passive-ftp" "--tries=4" "--wait=30" "--random-wait"))
(define wget-ftp-opts-force '("--timestamping"))

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

(define (justify-to-right this relative-to char)
  (let ((diff (- (string-length relative-to)
		 (string-length this))))
    (if (> diff 0)
	(display (make-string diff char)))))

					; string -> string -> string -> #{Unsped}
(define (notify rproto remote lproto local)
  (display " ")
  (justify-to-right rproto lproto #\space)
  (for-each display `(,rproto ": " ,remote " -> "))
  (newline)
  (display " ")
  (justify-to-right lproto rproto #\space)
  (for-each display `(,lproto ": " ,local " <- "))
  (newline))

;;; erm... for now we assume remote-file-name = local-file-name
;; directory parts are of course different "only"... you dummie!
(define (get-file-ftp-tmp local remote)
  (notify "ftp" remote "file" local)
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

;; it's not our business if local file exists, caller must decide
(define (get-file-ftp local remote)
  (notify "ftp" remote "file" local)
  (let* ((url (string-append "ftp://" remote))
	 (options (append (or (wget-opts)
			      wget-ftp-opts)
			  wget-ftp-opts-force))
	 (dir (file-name-directory local)))
    (let ((status (with-cwd dir
			    (run (wget ,@options ,url)))))
      (if (= status 0)
	  #t
	  #f))))
;; perhaps communicate status upword? wget's manpage is not enlightening.
; TOPONDER: AH, yes, the -S option, prints server response!
; -O option defeats --timestamping...