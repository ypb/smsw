;;; ACTIONS

;; upgrade
(define (upgrade-hints)
  (determine-external)
  (core-installed-or-missing))

;; DARN that's expensive (read: makes a user wait aaaaa moment - half a min -
; scsh ain't no speed demon)
; we should do it during make-installed-list; a new SUB-type perhaps?

; TOFIX both sort ov dan..
; find-pkg needs not use regexp-search... string=? is enough (no regex == 3x faster)
; pkg format should hold package name as simple string

; TODO improve see/ing display.scm
(define l-pad '(left #\space))
(define r-pad '(right #\space))
; "num of remote" "lname" "lversion" "larch" "lbuild" "->" "rversion" "rarch" "rbuild"
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
		      (list "" "" "" "")))))) ; that's not nice

(define (lvb=rvb? lpkg pkg)
  (string=? (string-append (lpkg-version lpkg)
			   "-"
			   (lpkg-build lpkg))
			   ; TODO TODO TODO
	    (string-append (pkg-version pkg)
			   "-"
			   (pkg-build pkg))))

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
				 (not (lvb=rvb? pkg (car remote))))))
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
;      (display-list-pkgs tmp)
      (do-display-padded remote-core-pads (map remote-core->strings tmp))
      (display-total tmp) (notice-filtered core-uninstalled tmp) (newline))))

; "rsection" "rname" "rversion-build" "rarch" "rtag"
(define remote-core-pads (list r-pad l-pad r-pad r-pad r-pad))
(define (remote-core->strings pkg)
  (list (pkg-sect pkg)
	(pkg-name pkg)
	(string-append (pkg-version pkg)
		       "-"
		       (pkg-build pkg))
	(pkg-arch pkg)
	(symbol->string (pkg-tag pkg))))

;; AND finally... get-core-remote-packages-but-not-intalled
;; TODO way improve it and refactor in/out display
;; also would be nice to see versions of REMOTE in second wave, TODO done
; need to go in opposite direction and show NEW ADDs! TODO done

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

;; update aka "te deum meritum"

; "ltag" "lsect" "lname" "larch" "lver-build" "-"+ ">" "rver-build" "rarch" "rsect" "rtag"

(define (update-hints . opt) ; by sections? or tags, or or!?! ohr, shiny!
  (display "Update hints from (") (display (local-version))
  (display ") to (") (display (version)) (display ").") (newline)
  (let ((installed (if (null? opt)
		       (make-lpkg-list)
		       (find-lpkg 'tag (car opt) 0))))
; TODO SHIT! local do not have section!?!??!?!?!!111!1!1
    (let* ((local+remote (map (lambda (p)
			     (cons p
				   (find-pkg (lpkg-name p))))
			   installed))
	   (updatable (filter (lambda (l+r)
				(and (not (null? (cdr l+r)))
				     (not (lvb=rvb? (car l+r)
						    (cadr l+r)))))
			   local+remote))
	   (just+pad (list r-pad r-pad
			   l-pad l-pad r-pad
			   r-pad
			   l-pad
			   r-pad l-pad l-pad))
	   (final (map (lambda (l+r)
			 (let* ((l (car l+r))
				(r (cadr l+r))
				(ltag (lpkg-tag l))
				(lsect (lpkg-sect l))
				(rtag (pkg-tag r))
				(rsect (pkg-sect r)))
;;; TOPONDER... on which end do we stringify?
			   (list (if ltag
				     (symbol->string ltag)
				     "")
				 (or lsect "-")
				 (lpkg-name l)
				 (lpkg-arch l)
				 (string-append (lpkg-version l)
						"-"
						(lpkg-build l))
				 (string-append (make-string (length (cdr l+r))
							     #\-)
						">")
				 (string-append (pkg-version r)
						"-"
						(pkg-build r))
				 (pkg-arch r)
				 (or rsect "-")
				 (if rtag
				     (symbol->string rtag)
				     ""))))
		       updatable)))
      (do-display-padded just+pad final)
      (display-total final) (newline))))
