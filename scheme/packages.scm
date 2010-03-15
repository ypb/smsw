
;;; This is scheme's config file... nothing to do with slackware.

;; help
(define-interface smsw-help-interface
  (export help))

(define-structure smsw-help smsw-help-interface
  (open scheme
	smsw-config)
  (files "help/help.scm"))

;; global and variables
(define-interface smsw-globals-interface
  (export SMSW_ETC
	  SMSW_VAR
	  ; semi external and vars 
	  SMSW_TMP
	  ; sane-options?
	  slackware-version
	  protocol
	  mirror-string
	  version
	  wget-opts
	  ; mirs
	  current-mirror
	  mirrors-list
	  mirror-name
	  mirror-path))

(define-structure smsw-globals smsw-globals-interface
  (open scheme
	smsw-externals
	smsw-config)
  (files "globals/vars.scm"
	 "globals/mirs.scm"))

(define-structure smsw-externals
  (export SMSW_ETC
	  SMSW_VAR)
  (open scheme)
  (files "globals/external.scm"))

;; config needs extertalns but globals uses config...
(define-interface smsw-config-interface
  (export load-config
	  ; config-sane?
	  get-main
	  get-mirrors))

(define-structure smsw-config smsw-config-interface
  (open scheme-with-scsh
	smsw-externals
	smsw-utils)
  (files "config/config.scm"
	 "config/read-mirs.scm"
	 "config/read-vars.scm"))

;; mirrors
(define-interface smsw-mirror-interface
  (export list-mirrors
	  init-mirrors
	  current-mirror-filelist))

(define-structure smsw-mirror smsw-mirror-interface
  (open scheme-with-scsh
	smsw-globals
	smsw-access
	smsw-utils)
  (files "mirror/mirror.scm"))

;; access
(define-structure smsw-access
  (export get-file)
  (open scheme-with-scsh
	smsw-globals
	smsw-utils)
  (files "access/access.scm"))

;; utils
(define-interface smsw-utils-interface
  (export typefy
	  verify-directory
	  verify-directories
	  mk-prepend-str
	  mk-append-str))

(define-structure smsw-utils smsw-utils-interface
  (open scheme-with-scsh)
  (files "utils/utils.scm"))

;; packages (finally)
(define-interface smsw-pkg-interface
  (export list-pkg
	  list-pkg-range
	  list-pkgs
	  find-pkg
	  get-pkg
	  pkg-stats
	  bootstrap
	  get-core-pkgs))

(define-structure smsw-pkg smsw-pkg-interface
  (open scheme-with-scsh
	tables
	smsw-mirror
	smsw-globals
	smsw-access
	smsw-utils)
  (files "pkg/pkg.scm"
	 "pkg/pkg-adt.scm"
	 "pkg/bootstrap.scm"))

;; main
(define-structure smsw (export)
  (open scheme ; but don't need it?
	smsw-help
	smsw-config
	smsw-mirror
	smsw-globals
	smsw-pkg))
