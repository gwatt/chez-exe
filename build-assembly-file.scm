(library (build-assembly-file)
  (export build-assembly-file)
  (import (chezscheme) (os-info))

  (define (build-assembly-file output-name start/end-name include-file)
    (with-output-to-file output-name
      (lambda ()
        (let ([start (name->linker-symbol (format "~a_start" start/end-name))]
              [end (name->linker-symbol (format "~a_end" start/end-name))])
          (format #t ".global ~a~n" start)
          (format #t ".global ~a~n" end)
          (format #t "~a:~n" start)
          (format #t ".incbin ~s~n" include-file)
          (format #t "~a:~n" end)))
      '(replace)))
)
