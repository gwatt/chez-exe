
(define bootpath (car (command-line-arguments)))
(define sep (string (directory-separator)))
(unless bootpath
  (display "Must specify the path to the boot files" (standard-error-port))
  (exit 1))

(make-boot-file "boot" '()
  (string-append bootpath sep "petite.boot")
  (string-append bootpath sep "scheme.boot"))