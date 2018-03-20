
(include "utils.ss")

(define args (command-line-arguments))
(build-included-binary-file (car args) (cadr args) (caddr args))