
(let ([program-name
       (foreign-procedure "program_name" () string)])

  (scheme-program
    (lambda (fn . fns)
      (format #t "COMPILING: ~a ~a\n" fn fns)
      (command-line (cons (program-name) fns))
      (command-line-arguments fns)
      (load-program fn))))
