;;; ACTIONS

(define (upgrade-hints)
  (determine-external)
  (core-installed-or-missing))

; display
(define l-pad '(left #\space))
(define r-pad '(right #\space))
(define l/r-pads (list r-pad
		       l-pad r-pad r-pad r-pad
		       l-pad r-pad r-pad r-pad))

; using first remote first raw should equal "1" for all HA Ha ha, suuure!?, you bugger!
; not so trivial after all, local critical may be in the first list of renamed/discontinued...
(define (local/remote lpkg)
  (let* ((remotes (find-pkg (lpkg-name lpkg)))
	(num (length remotes)))
    (cons (number->string num)
	  (append (lpkg->strings lpkg)
		  (if (not (zero? num))
		      (cons "->"
			    (cdr (pkg-nvab (car remotes))))
		      (list "" "" "" ""))))))

(define (core-installed-or-missing)
  (display "Installed \"critical\" packages of DIFFERENT version:")
  (let ((ignore-ADDs (read-ignoreadd)))
    (notice-filtering "IA" ignore-ADDs) (newline)
    (let* ((local-ADD-pkgs (find-lpkg 'tag 'ADD 0))
	   (tmp (if (not (null? ignore-ADDs))
		    (filter (lambda (pkg)
			      (not (member (lpkg-name pkg)
					   ignore-ADDs)))
			    local-ADD-pkgs)
		    local-ADD-pkgs))
	   (slow (filter (lambda (pkg)
			   (let ((remote (find-pkg (lpkg-name pkg))))
			     (or (null? remote)
				 (not (string=? (string-append (lpkg-version pkg)
							       "-"
							       (lpkg-build pkg))
						; TODO TODO TODO
						(string-append (pkg-version (car remote))
							       "-"
							       (pkg-build (car remote))))))))
			 tmp)))
; TOFIX and yet another filter on version inequality... do the work in one place
     (do-display-padded l/r-pads (map local/remote slow)) ; tmp
;;      (for-each just-display (map local/remote tmp))
;      (list-nicely tmp)
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
; TOFIX sort ov dan..
; find-pkg needs not use regexp-search... string=? is enough (no regex == 3x faster)
; pkg format should hold package name as simple string
