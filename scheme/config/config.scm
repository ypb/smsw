
(define debug #t)

(define (full-path config)
  (string-append SMSW_ETC "/" config))

(define configs '())

(define (init-configs)
  (if (null? configs)
      (set! configs
	    (list `(mirrors ,(full-path "mirrors")
			    ,(default-loader read-mirror))
		  `(main ,(full-path "main")
			 ,(default-loader read-variable))))))

(define config '())

(define (get-section sect)
  (if (not (null? config))
      (let ((tmp (assq sect config)))
	(if tmp (cdr tmp)
	    '()))
      '()))

(define (get-main) (get-section 'main))
(define (get-mirrors) (get-section 'mirrors))

(define (load-config)
  (init-configs)
  (let ((tmp (map load-config-file configs)))
    (if (null? config)
	(display "Setting ")
	(display "Resetting "))
    (set! config tmp)
    (display "config.")
    (newline)
    tmp))

;;; TODO abstract
(define (load-config-file config)
  `(,(car config)
    ,@(load-config-file-with (cadr config)
			     (caddr config))))
;load-debugging))

(define (load-config-file-with path proc)
  (if (file-readable? path)
      (load-with-proc path proc)
      (begin (display (string-append "Config file: "
				     path
				     " not readable."))
	     (newline)
	     '())))

;; file is readable

(define (load-with-proc from-file proc)
  (with-input-from-file from-file
    (lambda ()
      (let loop ((r (read)))
	(if (not (eof-object? r))
	    (proc r (loop (read)))
	    '())))))

;; loader procs construction (see other .scms)

(define (default-loader spec)
  (before-cons-beforeform if-debug
			  cons
			  spec))

(define (load-debugging form rest)
  (typefy form)
  (newline)
  (cons form rest))

(define (if-debug form)
  (if debug
      (begin (typefy form)
	     (newline))))

(define (before-cons-beforeform b cons bf)
  (lambda (form rest)
    (b form)
    (cons (bf form) rest)))

;;; (define-variable section name shape)

;; (define-variable 'main 'current '(number))
;; (define-variable 'main 'access 