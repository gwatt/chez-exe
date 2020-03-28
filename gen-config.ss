#!/usr/bin/env scheme-script
(import (except (chezscheme) scheme))
(include "utils.ss")

(define scheme (make-parameter "scheme"))
(define bootpath (make-parameter "."))
(define prefixdir
  (make-parameter
    (case (os-name)
      [windows (string-append (getenv "LOCALAPPDATA") "\\chez-exe")]
      [else "/usr/local"])))
(define libdir (make-parameter #f))
(define bindir (make-parameter #f))

(define args
  (param-args (command-line-arguments)
    [#f "--help" (lambda ()
                   (printlns
                     "Usage:"
                     "gen-config.ss [--prefix prefix] [--bindir bindir]"
                     "   [--libdir libdir] [--bootpath bootpath]"
                     "   [--scheme scheme] [c-compiler-arg ...]"
                     ""
                     "  --scheme: path to scheme exe"
                     "  --bootpath: path to boot files"
                     "  --prefix: root path for chez-exe installation"
                     "  --libdir: path to location for install of chez-exe libraries"
                     "  --bindir: path to location for install of chez-exe binaries"
                     ""
                     " On UNIX-like machines, bindir and libdir default to"
                     " $prefix/bin and $prefix/lib respectively, and the default"
                     " for prefix is /usr/local"
                     " On Windows, bindir and libdir both default to $prefix, and the"
                     " default for prefix is %LOCALAPPDATA%\\chez-exe")
                   (exit))]
    ["--scheme" scheme]
    ["--bootpath" bootpath]
    ["--prefix" prefixdir]
    ["--libdir" libdir]
    ["--bindir" bindir]))

(unless (libdir)
  (libdir
    (case (os-name)
      [windows (prefixdir)]
      [else
       (string-append (prefixdir) "/lib")])))
(unless (bindir)
  (bindir
    (case (os-name)
      [windows (prefixdir)]
      [else
       (string-append (prefixdir) "/bin")])))

(with-output-to-file "config.ss"
  (lambda ()
    (write `(chez-lib-dir ,(libdir)))
    (write `(static-compiler-args ',args)))
  '(replace))

(case (os-name)
  [windows
   (with-output-to-file "tools.ini"
     (lambda ()
       (printlns
         "[NMAKE]"
         (format "scheme = ~a" (scheme))
         (format "bootpath = ~a" (bootpath))
         (format "installbindir = ~a" (bindir))
         (format "installlibdir = ~a" (libdir))))
     '(replace))]
  [else
   (with-output-to-file "make.in"
     (lambda ()
       (printlns
         (format "CFLAGS += -m~a" (machine-bits))
         (format "scheme = ~a" (scheme))
         (format "bootpath = ~a" (bootpath))
         (format "prefix = ~a" (prefixdir))
         (format "installlibdir = ~a" (libdir))
         (format "installbindir = ~a" (bindir))))
     '(replace))])

(system "make")
