
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

(define (trim-whitespace str)
  (let ((pat (rx (+ (~ whitespace)))))
    (match:substring (regexp-search pat str))))
(define (is-comment? str)
  (let ((pat (rx (: bos (* whitespace) "#" any))))
    (regexp-search? pat str)))

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

;; Emilio C. Lopes <eclig@gmx.net>, 2005-10-10

(define (grep-port regexp port printer)
  (do ((line (read-line port) (read-line port))
       (line-number 1 (+ line-number 1)))
      ((eof-object? line) 'done)
    (if (regexp-search? regexp line)
        (printer line-number line))))

(define (grep regexp file)
  (call-with-input-file file
    (lambda (port)
      (grep-port regexp port (lambda (lineno line) (format #t "~a:~a:~a~%" file lineno line))))))
