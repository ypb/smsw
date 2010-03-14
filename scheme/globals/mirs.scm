
(define mirrors-list get-mirrors)

; format (mirror (name . "name") (host . "host") (access (method . "path") ...))

(define (mirror-get part mir)
  (if (mirror? mir)
      (let ((tmp (assq part (cdr mir))))
	(and tmp (cdr tmp)))
      #f))
;; hmmm
(define (mirror-name mir)
  (mirror-get 'name mir))
(define (mirror-host mir)
  (mirror-get 'host mir))
(define (mirror-paths mir)
  (mirror-get 'access mir))

(define (mirror-path mir)
  (let ((host (mirror-host mir))
	(paths (mirror-paths mir))
	(sv (slackware-version))
	(prot (protocol)))
    (and prot
	 paths
	 host
	 sv
	 (let ((path
		(let ((tmp (assq prot paths)))
		  (and tmp (cdr tmp)))))
	   (and path
		(string-append host
			       "/"
			       path
			       "/"
			       sv))))))
      
; at least a name?
(define (mirror? mir)
  (and (pair? mir)
       (eq? 'mirror (car mir))
       (not (null? (cdr mir)))
       (assq 'name (cdr mir))))

(define (current-mirror)
  (let ((tmp (mirrors-list)))
    (if (not (null? tmp))
	(let ((mn (mirror-string)))
	  (let search ((m (car tmp))
		       (l (cdr tmp)))
	    (if (equal? mn (mirror-name m))
		m
		(if (null? l)
		    #f
		    (search (car l) (cdr l))))))
	#f)))
