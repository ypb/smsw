
(define empty '(()))

(define var-readers '())

;;; hmmm
(define (read-variable sexp)
  (if (not (pair? sexp))
      empty
      (understood? (car sexp)
		   (cdr sexp))))

; TODO #f consider what to return - empty pair? '(()) same for mirrors?

(define (understood? var value)
  (let ((r (get-var-reader var)))
    (if r
	(cons var
	      (r value))
	empty)))

(define (get-var-reader var)
  (let ((tmp (assq var var-readers)))
    (and tmp (cdr tmp))))

(define (add-var-reader var proc)
  (if (not (get-var-reader var))
      (set! var-readers
	    (cons (cons var proc) var-readers))))

; common cases
(define (read-symbol->string val)
  (symbol->string (car val)))
(define (read-list-of-strings val)
  (map symbol->string val))
; confusing...

(add-var-reader 'current
		(lambda (val)
		  (let ((ver (car val)))
		    (if (symbol? ver)
			(symbol->string ver)
			ver))))

(add-var-reader 'mirror
		read-symbol->string)

(add-var-reader 'mirrors
		read-list-of-strings)

(add-var-reader 'access
		(lambda (val) (car val)))

(add-var-reader 'repo
		read-symbol->string)

(add-var-reader 'wget
		read-list-of-strings)
