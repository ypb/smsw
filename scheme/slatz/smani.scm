
(define MANIFEST (string-append SMSW_VAR "/MANIFEST"))

;; OH, NOH! 120s searching through:
;; root@chaitinia:~# wc ~/smsw/13.0-MANIFEST
;;   344240  2049863 31558558 /root/smsw/13.0-MANIFEST

(define (smani-nonono posix-sregexp)
  (grep (posix-string->regexp posix-sregexp)
	MANIFEST))

(define (smani-pkgs posix-sregexp)
  (smani 'pkgs posix-sregexp))
(define (smani-full posix-sregexp)
  (smani 'full posix-sregexp))

(define (smani opt posix-sregexp)
  (if (and (file-exists? MANIFEST)
	   (file-readable? MANIFEST))
      (let ((epattern (string-append "^\\|\\|.*Packa|"
				     posix-sregexp))
	    (thirdF (case opt
		      ((full) '(grep -v -- "^--$"))
		      ((pkgs) '(grep "^|| *Package: "))
		      (else '(grep -v -- "^--$")))))
	(run (| (grep -E ,epattern ,MANIFEST)
	        (grep -B1 -E "^[^\\|]")
                ,thirdF)))
;	        (grep -v -- "^--$"))))
      (begin (display "MANIFEST file: ")
	     (display MANIFEST)
	     (display " not found.")
	     (newline))))
