
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

(define (lpkg? lpkg)
  (and (pair? lpkg)
       (pair? (car lpkg))
       (eq? 'lpkg (caar lpkg))))

(define (lpkg-type lpkg)
  (cadar lpkg))
(define (lpkg-tag lpkg)
  (caddar lpkg))
(define (lpkg-sect lpkg)
  (cadddr (lpkg-head lpkg)))

(define lpkg-head car)

(define (lpkg-name lpkg)
  (raw-lpkg-name (cdr lpkg)))
(define (lpkg-version lpkg)
  (raw-lpkg-version (cdr lpkg)))
(define (lpkg-arch lpkg)
  (raw-lpkg-arch (cdr lpkg)))
(define (lpkg-build lpkg)
  (raw-lpkg-build (cdr lpkg)))
(define (lpkg-full-name lpkg)
  (raw-lpkg-full-name (cdr lpkg)))

;; raw from read
(define raw-lpkg-name car)
(define raw-lpkg-version cadr)
(define raw-lpkg-arch caddr)
(define raw-lpkg-build cadddr)
(define raw-lpkg-full-name reassemble)

;; like make-core-list
(define (make-installed-list raw-list)
  (if (null? raw-list)
      '()
      (let ((sver-num-str (extract-etc-version)))
	(if (not sver-num-str)
	    (begin (display "Couldn't get OS version.")
		   (newline)
		   '())
	    (let* ((tag-hash (get-pkg-tags (string-append "slackware-"
							  sver-num-str)))
		   (pkg-maker (mk-lpkg-maker 'installed tag-hash)))
	      (let loop ((l raw-list))
		(if (null? l)
		    '()
		    (cons (pkg-maker (car l))
			  (loop (cdr l))))))))))

; let's for now mimic pkg format...
; lpkg-format (('lpkg 'type 'tag "sect") "name" "version" "arch" "build")
; perhaps arch a symbol and build must be a number?

(define (mk-lpkg-maker type tag-cloud)
  (if tag-cloud
      (lambda (raw-lpkg)
	(let ((name (raw-lpkg-name raw-lpkg)))
	  (cons (list 'lpkg
		      type
		      (table-ref tag-cloud name)
		      #f) ; ekhem
		raw-lpkg)))
      (lambda (raw-lpkg)
	(cons (list 'lpkg
		    type
		    #f
		    #f)
	      raw-lpkg))))

;; TOPONDER if we get bogus string like 11.0.0 many things may break!
(define (extract-etc-version)
  (let ((vfile "/etc/slackware-version")
	(match (rx (: (+ numeric)
		      "."
		      numeric))))
    (if (file-exists? vfile)
	(let ((smth (read-etc-smth vfile)))
	  (and smth
	       (match:substring (regexp-search match
					       smth))))
	(begin (display "File ")
	       (display vfile)
	       (display "does not exist.")
	       (newline)
	       #f))))

(define (read-etc-smth file)
  (let ((match (rx (: bos
		      "Slackware "
		      (+ numeric)
		      (* any)))))
    (with-input-from-file file
      (lambda ()
	(let loop ((line (read-line)))
	  (if (not (eof-object? line))
	      (if (regexp-search? match line)
		  line
		  (loop (read-line)))
	      #f))))))

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
;  (list-nicely lpkglst))
  (list-nicely (make-lpkg-list)))

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
			 (display " ")
			 (display (cons (lpkg-tag lpkg)
					(lpkg-sect lpkg)))
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
