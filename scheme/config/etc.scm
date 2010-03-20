
;; local-version (perhaps it belongs in with config stuff?)

;; TODO...? cache modification or creation time of the file?

;; TOPONDER if we get bogus string like 11.0.0 many things may break!
(define (read-local-version)
  (let ((vfile "/etc/slackware-version")
	(match (rx (: (+ numeric)
		      "."
		      numeric))))
    (if (file-exists? vfile)
	(let ((smth (read-etc-smth vfile)))
	  (and smth
	       (match:substring (regexp-search match
					       smth))))
	(begin (display "File ")
	       (display vfile)
	       (display "does not exist.")
	       (newline)
	       #f))))

(define (read-etc-smth file)
  (let ((match (rx (: bos
		      "Slackware "
		      (+ numeric)
		      (* any)))))
    (with-input-from-file file
      (lambda ()
	(let loop ((line (read-line)))
	  (if (not (eof-object? line))
	      (if (regexp-search? match line)
		  line
		  (loop (read-line)))
	      #f))))))
