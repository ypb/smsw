
(define idir "/var/adm/packages")

(define lpkglst '())

;;; external getters
; display nicely!
; (define (list-installed))
; actual list
(define (installed-list)
  lpkglst)

(define (get-installed)
  (if (and (file-exists? idir)
	   (file-directory? idir)
	   (file-readable? idir))
      (let ((ipkgs (with-cwd idir (glob "*"))))
	(map string->lpkg ipkgs))
      (begin (display "Trouble with ")
	     (display idir)
	     (newline)
	     '())))
; also handles foo/bar/pkg.tgz NOT... there are dots in versions...
(define (string->lpkg str)
  (let* ((tmp (get-only-name-part str))
	 (split ((infix-splitter (rx "-")) tmp)))
    (if (not (< 3 (length split)))
	(begin (display "Not a proper pkg name: ")
	       (display str)
	       (newline)
	       #f)
	(let* ((name-parts (list-butt split 3))
	       (count (length name-parts)))
	  (list (reassemble name-parts)
		(list-ref split count)
		(list-ref split (+ count 1))
		(list-ref split (+ count 2)))))))

; this not working... (file-name-sans-extension (file-name-nondirectory str))
; get ONLY "name" part
(define (get-only-name-part frag)
  (let ((extricator (rx (: (submatch (* (: (* any) "/")))
			   (submatch (* (~ "/")))
			   (submatch (| eos
					(| ".txz" ".tgz"
					   ".txt"
					   ".txz.asc"
					   ".tgz.asc")))))))
    (match:substring (regexp-search extricator frag) 2)))
;;; hmmm... seems to work, not sure about that 2 here ^

(define lpkg-name car)
(define lpkg-version cadr)
(define lpkg-arch caddr)
(define lpkg-build cadddr)
(define lpkg-full-name reassemble)

;; good patter?
(define (verify-lpkg-list)
  (verify-list lpkglst))

(define (verify-list lst)
  (if (null? lst)
      '()
      (let loop ((l lst))
	(if (null? l)
	    #t
	(let ((lpkg (car l)))
	  (and (file-exists? (string-append idir
					    "/"
					    (lpkg-full-name lpkg)))
	       (loop (cdr l))))))))
;; TODO needs rewriting if we change format of the lpkg

(define (list-installed)
  (list-nicely lpkglst))

(define (list-nicely localpkgs)
  (if (not (null? localpkgs))
      (let* ((mk-l-padder (padder-maker 'left #\space))
	     (mk-r-padder (padder-maker 'right #\space))
	     (maxima (max-parts-lengths localpkgs))
	     (name-pad (mk-l-padder (car maxima)))
	     (vers-pad (mk-r-padder (cadr maxima)))
	     (arch-pad (mk-r-padder (caddr maxima)))
	     (buil-pad (mk-r-padder (cadddr maxima))))
	(for-each (lambda (lpkg)
			 (display " ")
			 (name-pad (lpkg-name lpkg))
			 (display " ")
			 (vers-pad (lpkg-version lpkg))
			 (display " ")
			 (arch-pad (lpkg-arch lpkg))
			 (display " ")
			 (buil-pad (lpkg-build lpkg))
			 (newline))
		  localpkgs))))

(define (max-parts-lengths lst)
  (let loop ((n 0) (v 0) (a 0) (b 0) (l lst))
    (if (null? l)
	(list n v a b)
	(let ((lpkg (car l)))
	  (if lpkg
	      (loop (max n (string-length (lpkg-name lpkg)))
		    (max v (string-length (lpkg-version lpkg)))
		    (max a (string-length (lpkg-arch lpkg)))
		    (max b (string-length (lpkg-build lpkg)))
		    (cdr l))
	      (loop n v a b (cdr l)))))))

;; OH curry
(define (mk-left-padder to char)
  (lambda (str)
    (let ((diff (- to
		   (string-length str))))
      (display str)
      (if (> diff 0)
	  (display (make-string diff char))))))

(define (mk-right-padder to char)
  (lambda (str)
    (let ((diff (- to
		   (string-length str))))
      (if (> diff 0)
	  (display (make-string diff char)))
      (display str))))

(define (padder-maker type char)
  (let ((left (lambda (num)
		(mk-left-padder num char)))
	(right (lambda (num)
		 (mk-right-padder num char))))
    (case type
      ((left) left)
      ((right) right)
      (else right))))
