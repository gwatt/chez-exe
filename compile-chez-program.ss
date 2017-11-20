
(import (chezscheme))

(define args (command-line-args))

(define (printlns . args)
  (for-each (lambda (x)
              (display x)
              (newline))
    args))

(define (join strings sep)
  (fold-left
    (lambda (acc str)
      (string-append acc sep str))
    (car strings)
    (cdr strings)))

(define (shell cmd)
  (let ([val (system cmd)])
    (unless (zero? val)
      (exit val))))

(unless (> (length args) 0)
  (parameterize ([current-output-port (current-error-port)])
    (printlns
      "Usage:"
      "compile-chez-program <scheme-program.ss> [args ...]"
      ""
      "This will compile a given scheme file and all of its imported libraries"
      "as with (compile-whole-program wpo-file output-file)"
      "see http://cisco.github.io/ChezScheme/csug9.5/system.html#./system:s68"
      "for documentation on compile-whole-program"
      ""
      "Any extra arguments will be passed to the c compiler"))
  (exit 1))

(compile-imported-libraries #t)
(generate-wpo-files #t)

(define scheme-file (car args))
(define compiler-args (cdr args))

(define basename
  (let loop ([idx (- (string-length scheme-file) 1)])
    (if (char=? (string-ref scheme-file idx) #\.)
        (substring scheme-file 0 idx)
        (loop (- idx 1)))))
(define wpo-file (string-append basename ".wpo"))
(define compiled-name (string-append basename ".chez"))

(compile-program scheme-file)
(compile-whole-program wpo-file compiled-name)

(define compile (join (cons* "cc -o" basename "chez.a" compiler-args) " "))

(shell compile)
(shell (join (list "objcopy" basename "--addsection" (string-append "schemeprogram=" compiled-name))))

(display basename)
(newline)
