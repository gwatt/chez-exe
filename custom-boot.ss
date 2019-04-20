
(let ([program-name
       (foreign-procedure "program_name" () string)])

  (scheme-program
    (lambda (fn . fns)
      (format #t "fn: ~a\nfns: ~a\nprogram-name: ~a\n" fn fns (program-name))
      (command-line (cons (program-name) fns))
      (command-line-arguments fns)
      (load-program fn))))
