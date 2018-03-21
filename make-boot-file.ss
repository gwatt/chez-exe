
(define bootpath (car (command-line-arguments)))
(define sep (string (directory-separator)))

(make-boot-file "boot" '()
  (string-append bootpath sep "petite.boot")
  (string-append bootpath sep "scheme.boot"))
