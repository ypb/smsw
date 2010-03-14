
; format (name host (access-type path [host]) ...) ...

(define (read-mirror-hmm sexp)
  (define (name m)
    `(name ,(symbol->string (car m))))
  (define (host m)
    `(host ,(symbol->string (cadr m))))
  (define (access a)
    `(,(car a) ,(symbol->string (cadr a))))
  (if (not (pair? sexp))
      #f
      (list 'mirror
	    (name sexp)
	    (host sexp)
	    `(access ,(map access (cddr sexp))))))

; TODO #f consider what to return - empty pair? '(())

(define (read-mirror sexp)
  (define (name m)
    (cons 'name (symbol->string (car m))))
  (define (host m)
    (cons 'host (symbol->string (cadr m))))
  (define (access a)
    (cons (car a) (symbol->string (cadr a))))
  (if (not (pair? sexp))
      #f
      (list 'mirror
	    (name sexp)
	    (host sexp)
	    (cons 'access (map access (cddr sexp))))))
