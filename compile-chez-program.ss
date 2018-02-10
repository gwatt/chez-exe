
(import (chezscheme))
(include "utils.ss")

(define-syntax param-args
  (syntax-rules ()
    [(_ arg-list-expr (opt param) ...)
      (let loop ([arg-list arg-list-expr])
        (if (null? arg-list)
            '()
            (case (car arg-list)
              [(opt) (if (null? (cdr arg-list))
                         (errorf 'param-args "Missing required argument for ~a" opt))
                (param (cadr arg-list))
                (loop (cddr arg-list))] ...
              [else arg-list])))]))

(define (printlns . args)
  (for-each (lambda (x)
              (display x)
              (newline))
    args))

(let
  ([libdirs (getenv "CHEZSCHEMELIBDIRS")]
   [libexts (getenv "CHEZSCHEMELIBEXTS")])
  (if libdirs (library-directories libdirs))
  (if libexts (library-extensions libexts)))

(define args
  (param-args (command-line-arguments)
    ["--libdirs" library-directories]
    ["--libexts" library-extensions]
    ["--srcdirs" (lambda (dirs)
                   (source-directories
                     (split-around dirs (path-separator))))]
    ["--optimize-level" (lambda (level)
                          (optimize-level (string->number level)))]))


(when (null? args)
  (parameterize ([current-output-port (current-error-port)])
    (printlns
      "Usage:"
      "compile-chez-program [--libdirs dirs] [--libexts exts] [--srcdirs dirs]
          [--optimize-level 0|1|2|3] <scheme-program.ss> [args ...]"
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

(define embed-file (string-append basename ".generated.c"))

(compile-program scheme-file)
(compile-whole-program wpo-file compiled-name)

(define solibs
  (case (os-name)
    [linux (if (threaded?)
               "-ldl -lm -ltinfo -lpthread"
               "-ldl -lm -ltinfo")]
    [macosx "-liconv -lncurses"]))

(build-included-binary-file embed-file "scheme_program" compiled-name)
(system (format "cc -o ~a chez.a ~a ~a ~a ~{ ~s~}" basename embed-file mbits solibs compiler-args))

(display basename)
(newline)
