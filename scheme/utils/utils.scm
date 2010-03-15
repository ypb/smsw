
(define (type-of this)
  (cond
   ((symbol? this) 'symbol)
   ((string? this) 'string)
   ((number? this) 'number)
   ((pair? this) 'pair)
   ((char? this) 'char)
   (else 'or-bool-vect-port-proc)))

(define (emit-type that of-this)
  (display "(")
  (write that)
  (display " ")
  (write of-this)
  (display ")"))

(define (typefy this)
  (cond
   ((eq? 'pair (type-of this))
    (begin (display "(pair ")
	   (typefy (car this))
	   (typefy-cdr (cdr this))
	   (display ")")))
   (else (emit-type (type-of this) this))))

(define (typefy-cdr this)
  (if (not (null? this))
      (begin (display " ")
	     (typefy (car this))
	     (typefy-cdr (cdr this)))))

(define (id x) x)

;;; MKDIR -p (sheesh)

; not real mkdir...
(define (mkdir dir)
  (if (file-exists? dir)
      (file-directory? dir)
      (begin (create-directory dir)
	     (file-directory? dir))))

; absolute... exists anyway.
(define (mkdir-rec dir rest)
  (if (equal? "" dir)
      (if (not (null? rest))
	  (mkdir-r (string-append "/" (car rest)) (cdr rest))
	  #f)
      (mkdir-r dir rest)))

; skip whitespace?
(define (mkdir-r dir rest)
      (if (null? rest)
	  (mkdir dir)
	  (let ((next (car rest)))
	    (if (equal? "" next)
		(mkdir-r dir (cdr rest))
		(and (mkdir dir)
		     (mkdir-r (string-append dir
					     "/"
					     (car rest))
			      (cdr rest)))))))
; DUMP... nah, but
(define (mkdir-poo dir)
  (if (equal? "" dir)
      #f
      (let ((split (split-file-name dir)))
	(mkdir-rec (car split) (cdr split)))))

;; BLEH

(define (mkdir-p dir)
  (if (equal? "" dir)
      #f
      (if (mkdir-up dir)
	  (mkdir dir)
	  #f)))

(define (mkdir-up dir)
  (let ((ladydee (file-name-directory
		  (directory-as-file-name dir))))
    (if (equal? "" ladydee)
	#t
	(if (mkdir-up ladydee)
	    (mkdir dir)
	    #f))))

(define (verify-directory dir)
  (if (and (file-exists? dir)
	   (file-directory? dir)
	   (file-writable? dir))
      #t
      (mkdir-p dir)))

(define (verify-directories root dirlst)
  (define (rec dir rest)
    (and (verify-directory (string-append root
					  "/"
					  dir))
	 (if (not (null? rest))
	     (rec (car rest) (cdr rest))
	     #t)))
  (and (verify-directory root)
       (if (not (null? dirlst))
	   (rec (car dirlst) (cdr dirlst))
	   #t)))

;;;

(define (mk-prepend-str with)
  (lambda (s)
    (string-append with s)))
(define (mk-append-str with)
  (lambda (s)
    (string-append s with)))
