;;; ACTIONS

(define (upgrade-hints)
  (display "Installed packages not found on the remote:")
  ; here would be a nice place to notify if we are filtering!
  (newline)
  (determine-external)
  (display "Installed \"critical\" packages:")
  ; there, too
  (newline)
  (let ((ignore-ADDs (read-ignoreadd)))
    (let ((tmp (if (not (null? ignore-ADDs))
		   (filter (lambda (lpkg)
			     (not (member (lpkg-name lpkg)
					  ignore-ADDs)))
			   (find-lpkg 'tag 'ADD 0))
		   (find-lpkg 'tag 'ADD 0))))
      (list-nicely tmp)
      (display-total tmp)))
  (display "Remote \"core\" packages not installed:")
  (newline)
  (let ((tmp (corepackages&uninstalled)))
    (display-list-pkgs tmp)
    (display-total tmp)))

;; AND finally... get-core-remote-packages-but-not-intalled
(define (corepackages&uninstalled)
  (filter (lambda (pkg)
	    (null? (find-lpkg 'name (pkg-name pkg) 0)))
	  (get-core-pkgs-list)))
;; TODO way improve it and refactor in/out display
;; also would be nice to see versions of REMOTE in second wave
; need to go in opposite direction and show NEW ADDs!

; dynamic
(define (make-lpkg-list)
  (make-installed-list (get-installed)))

;; list installed packages that are not in version looked upon (aka remote)

;; filter out known-external only when pkg is determined to be external!
(define (determine-external . opts)
  (let* ((known-externals (read-external))
	 (ext (if (null? known-externals)
		  (filter (lambda (lpkg)
			    (let ((pkg (find-pkg (lpkg-name lpkg))))
			      (null? pkg)))
			  (make-lpkg-list))
		  (filter (lambda (lpkg)
			    (let* ((name (lpkg-name lpkg))
				   (ext (find-pkg name)))
			      (and (null? ext)
				   (not (member name known-externals)))))
					; above looks funny, indeed.
			  (make-lpkg-list)))))
    (list-nicely ext)
    (display-total ext)))

; merely those installed that are present on remote, kinda redundant.
(define (determine-internal)
  (let ((int (filter (lambda (lpkg)
		       (let ((pkg (find-pkg (lpkg-name lpkg))))
			 (not (null? pkg))))
		     (make-lpkg-list))))
    (list-nicely int)
    (display-total int)))

(define (display-total lst)
  (if (not (null? lst))
      (begin (display "Total: ")
	     (display (length lst))
	     (newline))))

(define (find-lpkg by what . opt)
  (let ((display-or-how-raw (if (not (null? opt))
				(car opt)
				2))
	(tmp (find-lpkg-list by what)))
    (case display-or-how-raw
      ((0) tmp)
      ((1) (begin (display-list-lpkgs tmp)
		  (display-total tmp)))
      ((2) (begin (list-nicely tmp)
		  (display-total tmp))))))

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