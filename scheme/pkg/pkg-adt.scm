
(define (make-pkg-list raw-list type)
  (cond
   ((eq? 'core type) (make-core-list raw-list))
   (else (make-other-list raw-list))))

; pkg-format (('pkg 'type 'tag "sect") size-in-bytes "YYYY-MM-DD" "HH:MM" "path-frag")

(define (pkg? pkg)
  (and (pair? pkg)
       (pair? (car pkg))
       (eq? 'pkg (caar pkg))))
; for now...

(define (pkg-type pkg)
  (cadar pkg))
(define (pkg-tag pkg)
  (caddar pkg))
(define (pkg-sect pkg)
  (cadddr (pkg-head pkg)))

(define pkg-head car)

(define (pkg-path pkg)
  (raw-pkg-path (cdr pkg)))
(define (pkg-size pkg)
  (cadr pkg))
;; TOFIX: optimize? we could'av store it in the head?
(define (pkg-name pkg)
  (raw-pkg-name (cdr pkg)))
;; TOFIX assuming core
(define (pkg-path-full pkg)
  (case (pkg-type pkg)
    ((core) (string-append "slackware"
		 "/"
		 (pkg-path pkg)))
    (else (pkg-path pkg))))
; the best next worst thing to do... hug a BUG

;; RAW-package ADT...
(define raw-pkg-path cadddr)
;;; pkg name handling...
(define split-pkg-file-name (infix-splitter (rx "-")))
(define (list-butt lst num)
  (let ((until (- (length lst) num)))
    (cond
     ((<= until 0) '())
     ((= until 1) (cons (car lst) '()))
     (else (let loop ((u until) (l lst))
	     (if (= 0 u)
		 '()
		 (cons (car l) (loop (- u 1) (cdr l)))))))))
(define (reassemble parts)
  (if (null? parts)
      ""
      (let loop ((str (car parts)) (l (cdr parts)))
	(if (null? l)
	    str
	    (loop (string-append str "-" (car l))
		  (cdr l))))))
(define (raw-pkg-name pkg)
  (let* ((filename (file-name-nondirectory (raw-pkg-path pkg)))
	 (split (split-pkg-file-name filename))
	 (parts (list-butt split 3)))
    (reassemble parts)))

;;;

;; TOFIX and TODO omit comments like parsing! SHEESH AAAAAND trim whitespace...
; returns... hash-table of "short" pkg-names and their tag or #f
; SO very SO ugly...
(define (get-pkg-tags slackware-N)
  (let ((lstofiles (if (not slackware-N)
		       (current-mirror-filelist 'tagfiles)
		       (mirror-filelist/sv slackware-N 'tagfiles))) ; fragile
	(hash (make-string-table))
	(gotany? #f)) ; there is no point to bother if there is no tagfiles at all
    (for-each
     (lambda (f)
       (if f
	   (let ((tags (read-tags f)))
	     (if (not (null? tags))
		 (for-each
		  (lambda (t)
		    (let* ((name (car t))
			   (tag (cdr t))
			   (exists (table-ref hash name)))
		      (if exists
			  (begin (display "Package ")
				 (display name)
				 (display " ")
				 (display tag)
				 (display " duplicate while get-pkg-tags.")
				 (newline))
			  (table-set! hash name tag))))
		  tags))
	     (set! gotany? #t))))
     lstofiles)
    (and gotany? hash)))

(define (read-tags from-file)
  (let ((splitter (infix-splitter (rx ":"))))
    (with-input-from-file from-file
      (lambda ()
	(let loop ((line (read-line)))
	  (if (not (eof-object? line))
	      (if (not (is-comment? line))
		  (let ((split (splitter line)))
		    (if (= 2 (length split))
			(let ((name (trim-whitespace (car split)))
			      (tag (trim-whitespace (cadr split))))
			  (cons (cons name (string->symbol tag))
				(loop (read-line))))
			(loop (read-line))))
		  (loop (read-line)))
	      '()))))))
;; TOFIX ... perhaps check if tag is sane?

;; NOT good, but we think of 'core for now anyway, just a place-holder
(define (make-other-list raw-list) raw-list)

; get-pkg-tags is expensive fail early
(define (make-core-list raw-list)
  (if (null? raw-list)
      '()
      (let* ((tag-hash (get-pkg-tags #f)) ; use default settings
	     (pkg-maker (mk-pkg-maker 'core tag-hash)))
	(let loop ((l raw-list))
	  (if (null? l)
	      '()
	      (cons (pkg-maker (car l))
		    (loop (cdr l))))))))

;; almost exactly duplicated in local.scm (refinktor?)
(define (mk-pkg-maker type tag-hash)
  (if tag-hash
      (lambda (raw-pkg)
	(let ((name (raw-pkg-name raw-pkg)))
	  (cons (list 'pkg
		      type
		      (table-ref tag-hash name)
		      (core-raw-pkg-sect raw-pkg))
		(raw-pkg/size->number raw-pkg))))
      (lambda (raw-pkg)
	(cons (list 'pkg
		    type
		    #f
		    #f)
	      (raw-pkg/size->number raw-pkg)))))

(define (raw-pkg/size->number raw-pkg)
  (cons (string->number (car raw-pkg))
	(cdr raw-pkg)))

(define (core-raw-pkg-sect raw-pkg)
  (cadr (split-file-name (raw-pkg-path raw-pkg))))