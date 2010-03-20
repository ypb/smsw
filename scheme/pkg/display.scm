
;; GENERAL

; e.g. (foo-of-with max string-length '(("aaa" "ddd" "ererR") ...))
(define (foo-of-with foo measure lst)
  (if (null? lst)
      '()
      (let loop ((ret (map measure (car lst))) (l (cdr lst)))
	(if (null? l)
	    ret
	    (let ((tmp (car l)))
	      (if (not (null? tmp))
		  (loop (map foo ret (map measure tmp))
			(cdr l))
		  (loop ret (cdr l))))))))

(define (do-display-padded pads lls)
  (if (not (null? lls))
      (let* ((mk-padders (map (lambda (l)
				(apply padder-maker l)) pads))
	     (maxima (foo-of-with max
				  string-length
				  lls))
	     (padders (map (lambda (p m)
			     (p m))
			   mk-padders maxima)))
	(for-each (lambda (ls)
		    (for-each (lambda (p s)
				(display " ")
				(p s))
			      padders ls)
		    (newline))
		  lls))))

(define (just-display it)
  (display it)
  (newline))
    
;; REMOTE

(define (display-list-pkgs lst)
  (for-each (lambda (p)
	      (display (pkg-path-full p)) (newline))
	    lst))

;; LOCAL

(define (display-list-lpkgs lpkgs-lst)
  (for-each (lambda (p)
	      (display (lpkg-full-name p)) (newline))
	    lpkgs-lst))

(define (lpkg->strings lpkg)
  (cdr lpkg))

(define (list-nicely localpkgs)
  (if (not (null? localpkgs))
      (let* ((mk-l-padder (padder-maker 'left #\space))
	     (mk-r-padder (padder-maker 'right #\space))
	     (maxima (foo-of-with max
				  string-length
				  (map lpkg->strings
				       localpkgs)))
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

; that's so so solly.
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
