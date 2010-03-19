
;;; this is a no "no can do thing"... without it hash was being regenerated on each lpkg search... DUMMY!
(define tag-hash-cache '())
;;; sped up 2x without silly hash regeneration.

;; TOFIX and TODO omit comments like parsing! SHEESH AAAAAND trim whitespace...
; returns... hash-table of "short" pkg-names and their tag or #f
; SO very SO ugly...
;;(define (get-pkg-tags blah) (gen-name-tag-hash-for blah))
; noticed... can't (define exported-name some-internal-fun)
(define (get-pkg-tags slackware-N)
  ;; we could use loging facility since i can't imagine where this'll be called,
  ;; in grand scheme of display... i/o meets global state, TADA!
;  (display "get-pkg-tags release (")
;  (display slackware-N)
;  (display ").") (newline)
  (if slackware-N
      (let ((mem (assoc slackware-N tag-hash-cache)))
	(if mem
	    (cdr mem)
	    (let ((h (gen-name-tag-hash-for slackware-N)))
	      (if h
		  (begin (set! tag-hash-cache
			       (cons (cons slackware-N
					   h)
				     tag-hash-cache))
			 h)
		  #f))))
      ; again, we are fucked if we don't have it... for to remember you have so sign it.
      ; sign it with #f? that's nuts? the buck dies here.
      ; so for now we remember nothing...
      (gen-name-tag-hash-for slackware-N)))

(define (gen-name-tag-hash-for slackware-N)
  (let ((lstofiles (if (not slackware-N)
		       (current-mirror-filelist 'tagfiles)
		       (mirror-filelist/sv slackware-N 'tagfiles))) ; fragile
	(hash (make-string-table))
	(gotany? #f)) ; there is no point to bother if there is no tagfiles at all
    (if (not (pair? lstofiles))
	(begin (display "Tagfiles list not a list: ")
	       (display lstofiles)
	       (newline)
	       #f)
	(begin ;(display "gen-name-tag-hash-for release (")
	       ;(display slackware-N)
	       ;(display ").") (newline)
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
	       (and gotany? hash)))))

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
