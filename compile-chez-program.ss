
(import (chezscheme))
(include "utils.ss")

(define chez-file (make-parameter "chez.a"))

(meta-cond
  [(file-exists? "config.ss") (include "config.ss")])

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
                          (optimize-level (string->number level)))]
    ["--chez-file" chez-file]))


(when (null? args)
  (parameterize ([current-output-port (current-error-port)])
    (printlns
      "Usage:"
      "compile-chez-program [--libdirs dirs] [--libexts exts] [--srcdirs dirs]
          [--optimize-level 0|1|2|3] [--chez-file /path/to/chez.a]
          <scheme-program.ss> [c-compiler-args ...]"
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

(define basename (path-root scheme-file))

(define wpo-file (string-append basename ".wpo"))
(define compiled-name (string-append basename ".chez"))

(define embed-file (string-append basename ".generated.c"))

(compile-program scheme-file)
(compile-whole-program wpo-file compiled-name)

(define solibs
  (case (os-name)
    [linux (if (threaded?)
               "-ldl -lm -lpthread"
               "-ldl -lm")]
    [macosx "-liconv"]))

(build-included-binary-file embed-file "scheme_program" compiled-name)
(system (format "cc -o ~a ~a ~a ~a ~a ~{ ~s~}" basename (chez-file) embed-file mbits solibs compiler-args))

(display basename)
(newline)
