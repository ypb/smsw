;;; ACTIONS

(define (upgrade-hints)
  (determine-external)
  (core-installed-or-missing))

(define (core-installed-or-missing)
  (display "Installed \"critical\" packages:")
  (let ((ignore-ADDs (read-ignoreadd)))
    (notice-filtering "IA" ignore-ADDs) (newline)
    (let* ((local-ADD-pkgs (find-lpkg 'tag 'ADD 0))
	   (tmp (if (not (null? ignore-ADDs))
		    (filter (lambda (pkg)
			      (not (member (lpkg-name pkg)
					   ignore-ADDs)))
			    local-ADD-pkgs)
		    local-ADD-pkgs)))
      (list-nicely tmp)
      (display-total tmp) (notice-filtered local-ADD-pkgs tmp) (newline))
    (display "Remote \"core\" packages not installed:")
    (notice-filtering "IA" ignore-ADDs) (newline)
;;    (newline)
    (let* ((core-uninstalled (filter (lambda (pkg)
				       (null? (find-lpkg 'name (pkg-name pkg) 0)))
				     (get-core-pkgs-list)))
	   (tmp (if (not (null? ignore-ADDs))
		    (filter (lambda (pkg)
			      (not (member (pkg-name pkg)
					   ignore-ADDs)))
			    core-uninstalled)
		    core-uninstalled)))
      (display-list-pkgs tmp)
      (display-total tmp) (notice-filtered core-uninstalled tmp) (newline))))

(define (notice-filtering type lst)
  (if (not (null? lst))
      (begin (display " (filtering ")
	     (display type) (display "=")
	     (display (length lst))
	     (display ")"))))

(define (notice-filtered from to)
  (let ((start (length from))
	(end (length to)))
    (if (< end start)
	(begin (display " (filtered=")
	       (display (- start end))
	       (display ")")))))

;; AND finally... get-core-remote-packages-but-not-intalled
;; TODO way improve it and refactor in/out display
;; also would be nice to see versions of REMOTE in second wave
; need to go in opposite direction and show NEW ADDs!

;; list installed packages that are not in version looked upon (aka remote)

;; filter out known-external only when pkg is determined to be external!
(define (determine-external . opts)
  (display "Installed packages not found on the remote:")
  (let ((known-externals (read-external))
	(local-packages (make-lpkg-list)))
    (notice-filtering "KE" known-externals) (newline)
    (let* ((ext (filter (lambda (lpkg)
			  (let ((pkg (find-pkg (lpkg-name lpkg))))
			    (null? pkg)))
			local-packages))
	   (fnl (if (null? known-externals)
		    ext
		    (filter (lambda (lpkg)
			      (not (member (lpkg-name lpkg)
					   known-externals)))
			    ext))))
      (list-nicely fnl)
      (display-total fnl) (notice-filtered ext fnl) (newline))))

; merely those installed that are present on remote, kinda redundant.
(define (determine-internal)
  (let ((int (filter (lambda (lpkg)
		       (let ((pkg (find-pkg (lpkg-name lpkg))))
			 (not (null? pkg))))
		     (make-lpkg-list))))
    (list-nicely int)
    (display-total int) (newline)))

(define (display-total lst)
  (if (not (null? lst))
      (begin (display "Total: ")
	     (display (length lst)))))

(define (find-lpkg by what . opt)
  (let ((display-or-how-raw (if (not (null? opt))
				(car opt)
				2))
	(tmp (find-lpkg-list by what)))
    (case display-or-how-raw
      ((0) tmp)
      ((1) (begin (display-list-lpkgs tmp)
		  (display-total tmp) (newline)))
      ((2) (begin (list-nicely tmp)
		  (display-total tmp) (newline))))))

(define (display-list-lpkgs lpkgs-lst)
  (for-each (lambda (p)
	      (display (lpkg-full-name p)) (newline))
	    lpkgs-lst))

(define (list-lpkg whut)
  (find-lpkg 'sru whut))

(define (find-lpkg-list by critter)
  (case by
    ((name) (filter (lambda (lpkg)
		      (string=? critter (lpkg-name lpkg)))
		    (make-lpkg-list)))
    ((tag) (filter (lambda (lpkg)
		     (eq? critter (lpkg-tag lpkg)))
		   (make-lpkg-list)))
    ((sru) (filter (lambda (lpkg)
		    (regexp-search? (rx ,critter) (lpkg-full-name lpkg)))
		   (make-lpkg-list)))
    (else '())))

;; DARN that's expensive (read: makes a user wait aaaaa moment - half a min -
; scsh ain't no speed demon)
; we should do it during make-installed-list; a new SUB-type perhaps?
; TOFIX
; find-pkg needs not use regexp-search... string=? is enough (no regex == 3x faster)
; pkg format should hold package name as simple string
