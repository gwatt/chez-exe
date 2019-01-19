
(define output-file (car (command-line-arguments)))
(define bootfiles (cdr (command-line-arguments)))

(apply make-boot-file output-file '() bootfiles)
