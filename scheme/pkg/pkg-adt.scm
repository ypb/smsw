
; goal:
; (('pkg "name") files-by-releases statory)
; files-by-releases
; (('release (('pkg-file ("version" "arch" "build") ('type 'tag "sect") (size date md5sum ... etc)) ...)))
; statory
; (('installed . "version" ...) ('duplicate . release-list) ... )

; pkg-format (('pkg 'type 'tag "sect") size-in-bytes "YYYY-MM-DD" "HH:MM" "path-frag")
; transitional...
; pkg-format (('pkg ("name" "version" "arch" "build") ('type 'tag "sect")) size-in-bytes "YYY..." ... "path-frag")

(define (pkg? pkg)
  (and (pair? pkg)
       (pair? (car pkg))
       (eq? 'pkg (caar pkg))))
; for now...

(define pkg-head car)
(define (pkg-nvab p)
  (cadr (pkg-head p)))
(define (pkg-tts p)
  (caddr (pkg-head p)))

; how about using lpkg-name here, lol?
(define (pkg-name p)
  (car (pkg-nvab p)))
(define (pkg-version p)
  (cadr (pkg-nvab p)))
(define (pkg-arch p)
  (caddr (pkg-nvab p)))
(define (pkg-build p)
  (cadddr (pkg-nvab p)))
; nvab->{name,version,arch,build}?
(define (pkg-full-name p)
  (reassemble (pkg-nvab p)))

; TOFIX from -old format
(define (pkg-type-old pkg)
  (cadar pkg))
(define (pkg-type p)
  (car (pkg-tts p)))
(define (pkg-tag-old pkg)
  (caddar pkg))
(define (pkg-tag p)
  (cadr (pkg-tts p)))
(define (pkg-sect-old pkg)
  (cadddr (pkg-head pkg)))
(define (pkg-sect p)
  (caddr (pkg-tts p)))

; wobbly...
(define (pkg-path pkg)
  (raw-pkg-path (cdr pkg)))
(define (pkg-size pkg)
  (cadr pkg))
;; TOFIX: optimize? we could'av store it in the head?
(define (pkg-name-old pkg)
  (raw-pkg-name (cdr pkg)))
;; TOFIX assuming core
(define (pkg-path-full pkg)
  (case (pkg-type pkg)
    ((core) (string-append "slackware"
		 "/"
		 (pkg-path pkg)))
    (else (pkg-path pkg))))
; the best next worst thing to do... hug a BUG

(define (make-pkg-list raw-list type)
  (cond
   ((eq? 'core type) (make-core-list raw-list))
   (else (make-other-list raw-list))))

;; NOT good, but we think of 'core for now anyway, just a place-holder
(define (make-other-list raw-list) raw-list)

; get-pkg-tags is expensive fail early
(define (make-core-list raw-list)
  (if (null? raw-list)
      '()
      (let* ((tag-hash (get-pkg-tags #f)) ; use default settings
	     (pkg-maker (mk-pkg-maker 'core tag-hash)))
	(let loop ((l raw-list))
	  (if (null? l)
	      '()
	      (cons (pkg-maker (car l))
		    (loop (cdr l))))))))

;; almost exactly duplicated in local.scm (refinktor?)
(define (mk-pkg-maker-old type tag-hash)
  (if tag-hash
      (lambda (raw-pkg)
	(let ((name (raw-pkg-name raw-pkg)))
	  (cons (list 'pkg
		      type
		      (table-ref tag-hash name)
		      (core-raw-pkg-sect raw-pkg))
		(raw-pkg/size->number raw-pkg))))
      (lambda (raw-pkg)
	(cons (list 'pkg
		    type
		    #f
		    #f)
	      (raw-pkg/size->number raw-pkg)))))

(define (mk-pkg-maker type tag-hash)
  (if tag-hash
      (lambda (raw-pkg)
	(let ((nvab (raw-pkg-nvab raw-pkg)))
	  (cons (list 'pkg
		      nvab
		      (list type
			    (table-ref tag-hash (car nvab))
			    (core-raw-pkg-sect raw-pkg)))
		(raw-pkg/size->number raw-pkg))))
      (lambda (raw-pkg)
	(let ((nvab (raw-pkg-nvab raw-pkg)))
	  (cons (list 'pkg
		      nvab
		      (list type
			    #f
			    #f))
		(raw-pkg/size->number raw-pkg))))))
