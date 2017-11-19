
(import (chezscheme))

(define (printlns . args)
  (for-each (lambda (x)
              (display x)
              (newline))
    args))

(unless (= (length (command-line-arguments)) 1)
  (parameterize ([current-output-port (current-error-port)])
    (printlns
      "Usage:"
      (string-append (car (command-line)) " <scheme-program.ss>")))
  (exit 1))

(compile-imported-libraries #t)
(generate-wpo-files #t)

(define file (car (command-line-arguments)))
(define basename
  (let loop ([idx (- (string-length file) 1)])
    (if (char=? (string-ref file idx) #\.)
        (substring file 0 idx)
        (loop (- idx 1)))))
(define wpo-file (string-append basename ".wpo"))

(with-output-to-file "/dev/null"
  (lambda ()
    (compile-program file)
    (compile-whole-program wpo-file basename))
  '(append))

(display basename)
(newline)
