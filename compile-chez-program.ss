
(import (chezscheme))
(include "utils.ss")

(define chez-lib-dirs (make-parameter (list ".")))
(define static-compiler-args (make-parameter '()))
(define full-chez (make-parameter #f))
(define gui (make-parameter #f))
(define use-libkernel (make-parameter #f))

(meta-cond
  [(file-exists? "config.ss") (include "config.ss")])

(let
  ([libdirs (getenv "CHEZSCHEMELIBDIRS")]
   [libexts (getenv "CHEZSCHEMELIBEXTS")])
  (if libdirs (library-directories libdirs))
  (if libexts (library-extensions libexts)))

(define print-help-and-quit
  (case-lambda
    [() (print-help-and-quit 0)]
    [(code)
     (printlns
       "Usage:"
       " compile-chez-program [options ...] <scheme-program.ss> [c-compiler-args ...]"
       "Options:"
       " [--libdirs dirs]"
       " [--libexts exts]"
       " [--srcdirs dirs]"
       " [--chez-lib-dirs dirs]"
       " [--optimize-level 0|1|2|3]"
       " [--debug-level 0|1|2|3]"
       " [--commonization-level 0|1|...|9]"
       " [--compile-profile source|block]"
       " [--full-chez]"
       " [--compile-all-expressions]"
       " [--undefined-variable-warnings]"
       " [--generate-covin-files]"
       ""
       "This will compile a given scheme file and all of its imported libraries"
       "as with (compile-whole-program wpo-file output-file)"
       "see https://cisco.github.io/ChezScheme/csug9.5/system.html#./system:s77"
       "for documentation on compile-whole-program."
       ""
       "This instance of compile-chez-program was built with:"
       (string-append "    " (scheme-version))
       ""
       "Any extra arguments will be passed to the c compiler"
       "")
     (exit)]))

(define args
  (param-args (command-line-arguments)
    [#f "--help" print-help-and-quit]
    ["--libdirs" library-directories]
    ["--libexts" library-extensions]
    ["--srcdirs" (lambda (dirs)
                   (source-directories
                     (split-around dirs (path-separator))))]
    ["--optimize-level" (lambda (level)
                          (optimize-level (string->number level)))]
    ["--chez-lib-dirs" (lambda (dirs)
                         (chez-lib-dirs
                          (split-around dirs (path-separator))))]
    ;; accept --chez-lib-dir for compatibility:
    ["--chez-lib-dir" (lambda (dirs)
                        (chez-lib-dirs
                         (split-around dirs (path-separator))))]
    ["--debug-level" (lambda (level)
                       (debug-level (string->number level)))]
    ["--commonization-level" (lambda (level)
                               (commonization-level (string->number level)))]
    ["--compile-profile" (lambda (profile)
                           (compile-profile (string->symbol profile)))]
    [#t "--full-chez" full-chez]
    [#f "--compile-all-expressions" compile-interpret-simple]
    [#t "--undefined-variable-warnings" undefined-variable-warnings]
    [#t "--generate-covin-files" generate-covin-files]
    ;;; Windows only
    [#t "--gui" gui]))

(define (lib-file basename)
  (let* ([ext (if (eq? (os-name) 'windows)
                  "lib"
                  "a")]
         [libname (string-append basename "." ext)])
    (locate-file libname (chez-lib-dirs))))

(define chez-file (lib-file (if (full-chez)
                                "full-chez"
                                "petite-chez")))
(define libkernel-file (lib-file "libkernel"))
(define liblz4-file (lib-file "liblz4"))
(define libz-file (lib-file "libz"))
(when (null? args)
  (parameterize ([current-output-port (current-error-port)])
    (print-help-and-quit)))

(compile-imported-libraries #t)
(generate-wpo-files #t)

(define scheme-file (car args))
(define compiler-args (append (static-compiler-args) (cdr args)))

(define mbits (format #f "-m~a" (machine-bits)))

(define basename (path-root scheme-file))
(define exe-name
  (case (os-name)
    [windows (string-append basename ".exe")]
    [else basename]))

(define wpo-file (string-append basename ".wpo"))
(define compiled-name (string-append basename ".chez"))

(define embed-file (string-append basename ".generated.c"))

(compile-program scheme-file)
(compile-whole-program wpo-file compiled-name #t)

(define win-main
  (locate-file (if (gui)
                   "gui_main.obj"
                   "console_main.obj")
               (chez-lib-dirs)))

(define solibs
  (case (os-name)
    [linux (string-append
            "-ldl -lm -luuid -ltinfo"
            (if (threaded?) " -lpthread" ""))]
    [macosx "-liconv -ltinfo"]
    [windows "rpcrt4.lib ole32.lib advapi32.lib User32.lib"]))

(build-included-binary-file embed-file "scheme_program" compiled-name)
(case (os-name)
  [windows
   (system (format "cl /nologo /MD /Fe:~a ~a ~a ~a ~a ~{ ~a~}" exe-name win-main solibs chez-file embed-file compiler-args))]
  [else
   (system (apply format
                  (string-append "cc -o ~a ~a"
                                 (if (use-libkernel) " ~a ~a ~a" "")
                                 " ~a ~a ~a ~{ ~s~}")
                  (append (list exe-name chez-file)
                          (if (use-libkernel) (list libkernel-file liblz4-file libz-file) '())
                          (list embed-file mbits solibs compiler-args))))])

(display basename)
(newline)
