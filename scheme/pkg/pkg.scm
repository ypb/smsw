
(define pkgs-root (string-append SMSW_VAR "/Slackware"))

(define pkglist '())

(define (pkg-stats)
  (let ((num (length pkglist)))
    (display "Package statistics.") (newline)
    (display "Number of packages: ")
    (display num) (newline)
    `((count . ,num))))

;; MATCHERS
; in FILE{LIST,_LIST}
; match paths...
(define rx-paths (rx (: " ./" (+ alphabetic))))
; match paths... ending with .tgz TODO .txz on version >= 13.0
(define rx-pkg (rx (: " ./" (+ any) (| ".tgz" ".txz") eos)))
; LOL: Error: End-of-line regexp not supported in this implementation.

(define (get-pkgs)
  (let ((filelist (current-mirror-filelist 'core)))
    (if filelist
	(read-pkg-records filelist)
	(begin (display "No available filelist")
	       (newline)
	       #f))))
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

(define pkg-path cadddr)
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
(define (pkg-name pkg)
  (let* ((filename (file-name-nondirectory (pkg-path pkg)))
	 (split (split-pkg-file-name filename))
	 (parts (list-butt split 3)))
    (reassemble parts)))

;; TOFIX assuming core
(define (pkg-path-full pkg)
  (string-append "slackware"
		 "/"
		 (pkg-path pkg)))

;; (read-line [port handle-newline)
;; (regexp-search? re string [start flags])
;; (infix-splitter [delim num-fields handle-delim])

(define (display-list-pkgs lst)
  (for-each (lambda (p)
	      (display (cadddr p)) (newline))
	    lst))

(define (list-pkgs namefraglst . flag)
  (perhaps-init-pkglist flag)
  (let ((tmp (list-pkg-sre (build-or-sre namefraglst))))
    (display-list-pkgs tmp)
    tmp))
;;; HMMM...
(define (build-or-sre lst)
  (if (null? lst)
      (rx any)
      (let loop ((r (rx ,(car lst))) (l (cdr lst)))
	(if (null? l)
	    r
	    (loop (rx (| ,r ,(car l))) (cdr l))))))

(define (list-pkg namefragstr . flag)
  (perhaps-init-pkglist flag)
  (let ((tmp (list-pkg-sre (rx ,namefragstr))))
    (display-list-pkgs tmp)
    tmp))

(define (list-pkg-sre sre . flag)
  (perhaps-init-pkglist flag)
    (let loop ((l pkglist))
      (if (null? l)
	  '()
	  (let* ((pkg (car l))
		 (filename (file-name-nondirectory (pkg-path pkg)))
		 (match (regexp-search sre filename)))
	    (if match
		(cons pkg (loop (cdr l)))
		(loop (cdr l)))))))

(define (list-pkg-range from to . flag)
  (perhaps-init-pkglist flag)
  (let loop ((e 0) (l pkglist))
    (if (null? l)
	'()
	(if (and (>= e from)
		 (<= e to))
	    (cons (car l) (loop (+ e 1) (cdr l)))
	    (loop (+ e 1) (cdr l))))))

(define (perhaps-init-pkglist flaglst)
  (let ((f (if (not (null? flaglst))
	       (car flaglst)
	       #f)))
    (if (or f (null? pkglist))
	(init-pkglist))))

(define (init-pkglist)
  (let ((tmp (get-pkgs)))
    (if tmp
	(begin (if (null? pkglist)
	    (display "Setting ")
	    (display "Resetting "))
	       (set! pkglist tmp)
	       (display "pkglist.")
	       (newline)
	       #t)
	#f)))

;;; MOARE precise

;; exactly... but can search results of simpler list-pkg[s]
; not sure about usefulness such feature
; depends how dynamically we will store meta-list of packages...
(define (find-pkg name . opt)
  (let ((search (if (and (not (null? opt))
			 (eq? 'list (car opt))
			 (not (null? (cdr opt)))
			 (pair? (cadr opt)))
		    (cadr opt)
		    pkglist)))
    (let loop ((l search))
      (if (null? l)
	  '()
	  (let* ((pkg (car l))
		 (pkgname (pkg-name pkg))
		 (match (regexp-search (rx (: bos ,name eos)) pkgname)))
	    (if match
		(cons pkg (loop (cdr l)))
		(loop (cdr l))))))))
; should return exact one match, perhaps we should bail on first?

;; NOW the meat, ROFL WOOF WOOF

(define (get-pkg name)
  (let ((result (find-pkg name)))
    (if (not (= 1 (length result)))
	(begin (display "Ambiguous result.") (newline)
	       result)
	(map get-pkg-file (make-pkg-set (car result))))))

;; also need .txt and .asc files...
(define (make-pkg-set pkg)
  (let* ((path (pkg-path-full pkg))
	 (asc (string-append path ".asc"))
	 (txt (string-append (file-name-sans-extension path)
			     ".txt")))
    (list path asc txt)))

;; TOFIX... looks "almost" like just-get-file from "mirror.scm"
(define (get-pkg-file file)
  (let ((local-path (string-append pkgs-root
				   "/"
				   (slackware-version)
				   "/"
				   file)))
    (if (file-exists? local-path)
	#t
	(and (verify-directory (file-name-directory local-path))
	     (let ((remote-path (mirror-path (current-mirror))))
	       (if remote-path
		   (get-file local-path
			     (string-append remote-path
					    "/"
					    file))
		   (begin (display "Couldn't determine remote path.")
			  (newline)
			  #f)))))))
;; BUTT we are mising dir structure verification! SHIT
