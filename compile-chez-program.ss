
(import (chezscheme) (os-info) (build-assembly-file))

(define args (command-line-arguments))

(define (printlns . args)
  (for-each (lambda (x)
              (display x)
              (newline))
    args))

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

(define mbits (format #f "-m~a" (machine-bits)))

(define basename
  (let loop ([idx (- (string-length scheme-file) 1)])
    (if (char=? (string-ref scheme-file idx) #\.)
        (substring scheme-file 0 idx)
        (loop (- idx 1)))))

(define wpo-file (string-append basename ".wpo"))
(define compiled-name (string-append basename ".chez"))

(define asm-embed-file (string-append basename ".s"))

(compile-program scheme-file)
(compile-whole-program wpo-file compiled-name)

(define solibs
  (case (os-name)
    [linux (if (threaded?)
               "-ldl -lm -ltinfo -lpthread"
               "-ldl -lm -ltinfo")]
    [macosx "-liconv -lncurses"]))

(build-assembly-file asm-embed-file "scheme_program" compiled-name)
(system (format "cc -o ~a chez.a ~a ~a ~a ~{ ~s~}" basename asm-embed-file mbits solibs compiler-args))

(display basename)
(newline)
