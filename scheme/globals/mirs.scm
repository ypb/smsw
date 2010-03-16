
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

; of confusando de daynamic vs anemic named variably
(define (find-mirror mir-name-str mirs-lst)
  (if (not mir-name-str)
      ; this is awkward
      #f
      (let search ((l mirs-lst))
	(if (null? l)
	    #f
	    (let ((mir (car l)))
	      (if (equal? mir-name-str (mirror-name mir))
		  mir
		  (search (cdr l))))))))

;;; first-mirror sounds more like it
(define (current-mirror)
  (find-mirror (mirror-string) (mirrors-list)))
