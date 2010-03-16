
(define meta-root (string-append SMSW_VAR "/meta/mirrors"))

(define versions (list "13.0" "12.2" "12.1" "12.0" "11.0" "10.2" "10.1" "10.0"
		       "9.1" "9.0" "8.1"))
;(define core-subdirs (list "a"))
(define core-subdirs (list "a" "ap" "d" "e" "f" "k" "kde"
			   "kdei" "l" "n" "t" "tcl" "x" "xap" "y"))
; not really meta dirs but dirs inside each mirror...
(define meta-dirs (map (mk-prepend-str "slackware/") core-subdirs))
(define meta-files (list "ChangeLog.txt"
			 "FILELIST.TXT"
			 "PACKAGES.TXT"
			 "CHECKSUMS.md5"
			 "CHECKSUMS.md5.asc"
			 "GPG-KEY"
			 "slackware/CHECKSUMS.md5"
			 "slackware/CHECKSUMS.md5.asc"
			 "slackware/FILE_LIST"))

(define random-tagfils (list "install-packages"
			     "install.end"
			     "maketag"
			     "maketag.ez"
			     "tagfile"))


(define meta-other-files
  (map (mk-prepend-str "slackware/")
       (apply append
	      (map (lambda (x)
		     (map (mk-prepend-str (string-append x "/"))
			  random-tagfils))
		   core-subdirs))))

(define (list-mirrors)
  (let ((tmp (mirrors-list)))
    (if tmp
	(for-each (lambda (m)
		    (display (mirror-name m))
		    (newline))
		  tmp)
	(begin (display "No mirrors defined.")
	       (newline)))))

; humongous TODO... pull globals up to exported init-mirrors provider
; e.g. there is no point in doing anything if either of them three is empty
; this is not really initing mirrors but meta-data
(define (init-mirrors . opts)
  (if (verify-directory meta-root)
      (initing-first-mirror)))
; else error one you one-handed bandid.

; init-mirrors customers
(define (initing-mirrors)
  (display "Initing ALL mirrors' meta info.")
  (newline)
  (let ((tmp (mirrors-list)))
    (if tmp
	(for-each init-mirror
		  tmp))))

; we don't need "other" mirrors if first one works
(define (initing-first-mirror)
  (display "Initiating mirrors in preference order.")
  (newline)
  (let ((mir (current-mirror))
	(all-mirs (mirrors-list)))
    (if mir
	(init-mirror mir)
	(let follow ((l (mirror-strings)))
	  (if (null? l)
	      #f
	      (let ((mir (find-mirror (car l) all-mirs)))
		(if (not (and mir
			      (init-mirror mir)))
		    (follow (cdr l))
		    #t)))))))
;;

;;; TODO and TOFIX... don't verify dirs before actuall download?
;; creates empty junk!
;;; TODO and TOFIX... init only those in main not mirrors, dummy!

(define (init-mirror mir)
  (display (mirror-name mir))
  (newline)
  ; TODO move this into init-mirrors or some global sanity check
  ; (config-loaded? or verify?) can't be checking this shit on every
  ; function!
  (let ((md (string-append meta-root
			   "/"
			   (mirror-name mir)
			   "/"
			   (slackware-version))))
    (and (verify-directories md meta-dirs)
	 (populate-mirror mir md))))
;;; GOOD GOOF... resigns if can't get "some file"... e.g. first one.
(define (populate-mirror mir root)
  (let loop ((lst (append meta-files meta-other-files)))
    (if (null? lst)
	#t
	(and (just-get-file mir root (car lst))
	     (loop (cdr lst))))))

(define (just-get-file mir dir file)
  (let ((local-path (string-append dir
				   "/"
				   file)))
    (if (file-exists? local-path)
	#t
	(let ((remote-path (mirror-path mir)))
	  (if remote-path
	      (get-file local-path
			(string-append remote-path
				       "/"
				       file))
	      (begin (display "Couldn't determine remote path.")
		     (newline)
		     #f))))))

;; servicing pkg queries... HMMM...

(define (get-filelist path)
  (let ((mn (mirror-string))
	(sv (slackware-version)))
    (if (and mn sv)
	(let ((path (string-append meta-root
				   "/"
				   mn
				   "/"
				   sv
				   "/"
				   path)))
	  (if (file-readable? path)
	      path
	      (begin (display "File: ")
		     (display path)
		     (display " not readable.")
		     (newline)
		     #f)))
	(begin (display "Insane settings in 'get-filelist'.")
	       (newline)
	       #f))))

; 'core 'extra 'patches ? 'main ... "all"
(define (current-mirror-filelist . sym)
  (let ((choice (if (null? sym)
		    'main
		    (car sym))))
    (case choice
      ((main) (get-filelist "FILELIST.TXT"))
      ((core) (get-filelist "slackware/FILE_LIST"))
      ((tagfiles) (map get-filelist
		       (map (mk-prepend-str "slackware/")
			    (map (mk-append-str "/tagfile")
				 core-subdirs))))
      (else #f))))

;;; this is not-trivially fubared...

; (current-mirror-path)
