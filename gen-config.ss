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

(param-args (command-line-arguments)
  ["--scheme" scheme]
  ["--bootpath" bootpath]
  ["--prefix" prefixdir]
  ["--libdir" libdir]
  ["--bindir" bindir])

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
    (write `(chez-lib-dir ,(libdir))))
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
