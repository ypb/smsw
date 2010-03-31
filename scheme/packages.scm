
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
	  switch-release
	  local-version
	  ; sane-options?
	  slackware-version
	  protocol
	  mirror-string
	  mirror-strings ; list of preference
	  version
	  wget-opts
	  ; mirs
	  current-mirror
	  find-mirror
	  mirrors-list ; ALL defined
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
	  ; only here because we don't want to import more than scheme in -globals
	  read-local-version
	  ; config-sane?
	  get-main
	  get-mirrors))

(define-structure smsw-config smsw-config-interface
  (open scheme-with-scsh
	smsw-externals
	smsw-utils)
  (files "config/config.scm"
	 "config/etc.scm"
	 "config/read-mirs.scm"
	 "config/read-vars.scm"))

;; mirrors
(define-interface smsw-mirror-interface
  (export list-mirrors
	  init-mirrors
	  current-mirror-filelist
	  mirror-filelist/sv))

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

;; TDM: trivial download manager
(define-structure smsw-tdm
  (export wget)
  (open scheme-with-scsh
	srfi-1
	; only for now
	smsw-externals)
  (files "tdm/wwget.scm"))

;; utils
(define-interface smsw-utils-interface
  (export typefy
	  verify-directory
	  verify-directories
	  mk-prepend-str
	  mk-append-str
	  trim-whitespace
	  is-comment?
	  padder-maker))

(define-structure smsw-utils smsw-utils-interface
  (open scheme-with-scsh)
  (files "utils/utils.scm"))

;; packages (finally)
(define-interface smsw-pkg-interface
  (export bootstrap ; don't pay attention to the man behind the counter.
	  __bootstrap
	  ; remote...
          list-pkg
	  list-pkg-range ; to debug
	  list-pkgs
	  find-pkg
	  get-pkg
	  pkg-stats
	  get-core-pkgs
	  ; local
	  list-installed
	  upgrade-hints
	  update-hints
	  determine-external
	  determine-internal
	  find-lpkg
	  list-lpkg))

(define-structure smsw-pkg smsw-pkg-interface
  (open scheme-with-scsh
	tables
	srfi-1
	; ours
	smsw-mirror
	smsw-globals
	smsw-filters
	smsw-access
	smsw-utils)
  (files "pkg/pkg.scm"
	 "pkg/read-raw.scm"
	 "pkg/pkg-adt.scm"
	 "pkg/tags.scm"
	 "pkg/local.scm"
	 "pkg/display.scm"
	 "pkg/actions.scm"
	 "pkg/bootstrap.scm"))

;; filters
(define-structure smsw-filters
  (export read-external
	  read-ignoreadd)
  (open scheme-with-scsh
	smsw-externals)
  (files "blacklists/upgradehints.scm"))

;; main
(define-structure smsw-main
  (export start
	  move-to
	  status)
  (open scheme
	smsw-config
	smsw-mirror
	smsw-globals
	smsw-pkg)
  (files "smsw/manager.scm"))

;; main
(define-structure smsw (export)
  (open scheme ; but don't need it?
	smsw-help
	smsw-tdm
	smsw-main
	smsw-mirror
	smsw-pkg))
