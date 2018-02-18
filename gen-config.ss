#!/usr/bin/env scheme-script
(import (chezscheme))
(include "utils.ss")

(define bootpath (make-parameter "."))
(define prefixdir (make-parameter "/usr/local"))
(define libdir (make-parameter #f))
(define bindir (make-parameter #f))

(param-args (command-line-arguments)
  ["--bootpath" bootpath]
  ["--prefix" prefixdir]
  ["--libdir" libdir]
  ["--bindir" bindir])

(unless (libdir) (libdir (string-append (prefixdir) "/lib")))
(unless (bindir) (bindir (string-append (prefixdir) "/bin")))

(with-output-to-file "config.ss"
  (lambda ()
    (write `(chez-file ,(string-append (libdir) "/chez.a"))))
  '(replace))

(with-output-to-file "make.in"
  (lambda ()
    (printlns
      (string-append "bootpath ?= " (bootpath))
      (string-append "prefix = " (prefixdir))
      (string-append "installlibdir = " (libdir))
      (string-append "installbindir = " (bindir))))
  '(replace))
