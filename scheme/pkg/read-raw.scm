
;;; REMOTE (there is also LOCAL section down below)

;; MATCHERS
; in FILE{LIST,_LIST}
; match paths...
(define rx-paths (rx (: " ./" (+ alphabetic))))
; match paths... ending with .tgz, .txz on version >= 13.0
(define rx-pkg (rx (: " ./" (+ any) (| ".tgz" ".txz") eos)))
; LOL: Error: End-of-line regexp not supported in this implementation.

;; (read-line [port handle-newline)
;; (regexp-search? re string [start flags])
;; (infix-splitter [delim num-fields handle-delim])

; file exists
(define (read-pkg-records from-file)
  (let ((match rx-pkg)
	(split (infix-splitter)))
    (with-input-from-file from-file
      (lambda ()
	(let loop ((line (read-line)))
	  (if (not (eof-object? line))
	      (if (regexp-search match line)
		  (cons (list-tail (split line) 4) (loop (read-line)))
		  (loop (read-line)))
	      '()))))))

;; returns (("size" "YYYY-MM-DD" "HH:MM" "./foo/pkg-name-ver-arch-build(.tgz|.txz)") ...)
; see pkg-adt.scm for more

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

; '("name" "version" "arch" "build")
(define (raw-pkg-nvab pkg)
  (string->lpkg (raw-pkg-path pkg)))
; this is really co-mingling'em. or smart code reuse ;)

; random cosmetics

(define (raw-pkg/size->number raw-pkg)
  (cons (string->number (car raw-pkg))
	(cdr raw-pkg)))

(define (core-raw-pkg-sect raw-pkg)
  (cadr (split-file-name (raw-pkg-path raw-pkg))))

;;; LOCAL

;; raw from read, much cleaner compared to raw-pkg, but reusing them code.
(define raw-lpkg-name car)
(define raw-lpkg-version cadr)
(define raw-lpkg-arch caddr)
(define raw-lpkg-build cadddr)
(define raw-lpkg-full-name reassemble)

;; hmmm... using global var (idir), but it's held in local.scm...
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
; get ONLY "nvab" part
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
