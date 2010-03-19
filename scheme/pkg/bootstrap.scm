
;;; LOL it doesn't mean what i thought you would think it means.

(define (__bootstrap)
  (init-pkglist))

; Slackware 11.0
(define bootstrap-chroot-110
  '("aaa_base" "aaa_elflibs" "bash" "coreutils" "devs" "etc" "grep" "glibc-solibs" "gzip" "pkgtools" "tar"))

; Slackware 12.0
; Slackware 12.1

; Slackware 12.2
(define bootstrap-chroot-122
  '("aaa_base" "aaa_elflibs" "aaa_terminfo" "bash" "bin" "coreutils" "devs"
    "etc" "gawk" "grep" "gzip" "pkgtools" "sed" "tar"))
; 14

; Slackware 13.0
; "xz"
(define bootstrap-chroot-130
  (append bootstrap-chroot-122 '("xz")))

(define (bootstrap-chroot)
  (let ((v (version)))
    (cond
     ((equal? v "11.0") bootstrap-chroot-110)
     ((equal? v "12.2") bootstrap-chroot-122)
     ((equal? v "13.0") bootstrap-chroot-130)
     (else '()))))

(define (bootstrap)
  (map get-pkg (bootstrap-chroot)))
