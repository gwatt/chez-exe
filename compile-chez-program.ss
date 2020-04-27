
(import (chezscheme))
(include "utils.ss")

(define chez-lib-dir (make-parameter "."))
(define static-compiler-args (make-parameter '()))
(define full-chez (make-parameter #f))
(define gui (make-parameter #f))

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
       "compile-chez-program [--libdirs dirs] [--libexts exts] [--srcdirs dirs]"
       "    [--optimize-level 0|1|2|3] [--chez-lib-dir /path/to/chez.a]"
       "    [--full-chez] <scheme-program.ss> [c-compiler-args ...]"
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
    ["--chez-lib-dir" chez-lib-dir]
    [#t "--full-chez" full-chez]
    ;;; Windows only
    [#t "--gui" gui]))

(define chez-file
  (let* ([basename (if (full-chez)
                       "full-chez"
                       "petite-chez")]
         [ext (if (eq? (os-name) 'windows)
                  "lib"
                  "a")]
         [libname (string-append basename "." ext)])
    (path-append (chez-lib-dir) libname)))

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
  (path-append (chez-lib-dir)
    (if (gui)
        "gui_main.obj"
        "console_main.obj")))

(define solibs
  (case (os-name)
    [linux (if (threaded?)
               "-ldl -lm -luuid -lpthread"
               "-ldl -lm -luuid")]
    [macosx "-liconv"]
    [windows "rpcrt4.lib ole32.lib advapi32.lib User32.lib"]))

(build-included-binary-file embed-file "scheme_program" compiled-name)
(case (os-name)
  [windows
   (system (format "cl /nologo /MD /Fe:~a ~a ~a ~a ~a ~{ ~a~}" exe-name win-main solibs chez-file embed-file compiler-args))]
  [else
   (system (format "cc -o ~a ~a ~a ~a ~a ~{ ~s~}" exe-name chez-file embed-file mbits solibs compiler-args))])

(display basename)
(newline)
