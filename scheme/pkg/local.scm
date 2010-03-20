
(define idir "/var/adm/packages")

(define lpkglst '())

;;; external getters
; display nicely!
; (define (list-installed))
; actual list
(define (installed-list)
  lpkglst)

(define (list-installed)
;  (list-nicely lpkglst))
  (list-nicely (make-lpkg-list)))

(define (lpkg? lpkg)
  (and (pair? lpkg)
       (pair? (car lpkg))
       (eq? 'lpkg (caar lpkg))))

(define (lpkg-type lpkg)
  (cadar lpkg))
(define (lpkg-tag lpkg)
  (caddar lpkg))
(define (lpkg-sect lpkg)
  (cadddr (lpkg-head lpkg)))

(define lpkg-head car)

(define (lpkg-name lpkg)
  (raw-lpkg-name (cdr lpkg)))
(define (lpkg-version lpkg)
  (raw-lpkg-version (cdr lpkg)))
(define (lpkg-arch lpkg)
  (raw-lpkg-arch (cdr lpkg)))
(define (lpkg-build lpkg)
  (raw-lpkg-build (cdr lpkg)))
(define (lpkg-full-name lpkg)
  (raw-lpkg-full-name (cdr lpkg)))

; dynamic
(define (make-lpkg-list)
  (make-installed-list (get-installed)))
; see read-raw.scm

;; like make-core-list
(define (make-installed-list raw-list)
  (if (null? raw-list)
      '()
      (let ((sver-num-str (local-version)))
	(if (not sver-num-str)
	    (begin (display "Couldn't get OS version.")
		   (newline)
		   '())
	    (let* ((tag-hash (get-pkg-tags (string-append "slackware-"
							  sver-num-str)))
		   (pkg-maker (mk-lpkg-maker 'installed tag-hash)))
	      (let loop ((l raw-list))
		(if (null? l)
		    '()
		    (cons (pkg-maker (car l))
			  (loop (cdr l))))))))))

; let's for now mimic pkg format...
; lpkg-format (('lpkg 'type 'tag "sect") "name" "version" "arch" "build")
; perhaps arch a symbol and build must be a number?

(define (mk-lpkg-maker type tag-cloud)
  (if tag-cloud
      (lambda (raw-lpkg)
	(let ((name (raw-lpkg-name raw-lpkg)))
	  (cons (list 'lpkg
		      type
		      (table-ref tag-cloud name)
		      #f) ; ekhem
		raw-lpkg)))
      (lambda (raw-lpkg)
	(cons (list 'lpkg
		    type
		    #f
		    #f)
	      raw-lpkg))))

;; good pattern?
(define (verify-lpkg-list)
  (verify-list lpkglst))

(define (verify-list lst)
  (if (null? lst)
      '()
      (let loop ((l lst))
	(if (null? l)
	    #t
	(let ((lpkg (car l)))
	  (and (file-exists? (string-append idir
					    "/"
					    (lpkg-full-name lpkg)))
	       (loop (cdr l))))))))
;; TODO needs rewriting if we change format of the lpkg

;; searching
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
