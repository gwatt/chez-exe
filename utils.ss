(define (os-name)
  (case (machine-type)
    [(a6fb ta6fb i3fb ti3fb) 'freebsd]
    [(a6le arm32le i3le ppc32le ta6le ti3le tppc32le) 'linux]
    [(a6nb i3nb ta6nb ti3nb) 'netbsd]
    [(a6nt i3nt ta6nt ti3nt) 'windows]
    [(a6ob i3ob ta6ob ti3ob) 'openbsd]
    [(a6osx i3osx ta6osx ti3osx) 'macosx]
    [(a6s2 i3s2 ta6s2 ti3s2) 'solaris]
    [(i3qnx) 'qnx]))

(define (machine-bits)
  (* (ftype-sizeof void*) 8))

(define (path-separator)
  (case (os-name)
    [windows #\;]
    [else #\:]))

(define (path-append fst . rest)
  (fold-left
    (lambda (path str)
      (string-append path (string (directory-separator)) str))
    fst
    rest))

(define (build-included-binary-file output-name symbol-name include-file)
  (with-output-to-file output-name
    (lambda ()
      (let ([data (bytevector->u8-list (get-bytevector-all (open-file-input-port include-file)))])
        (format #t "#include <stdint.h>~n")
        (format #t "const uint8_t ~a[] = {~{0x~x,~}};~n" symbol-name data)
        (format #t "const unsigned int ~a_size = sizeof(~a);~n" symbol-name symbol-name)))
    '(replace)))

(define (split-around str ch)
  (let loop ([i 0] [start 0])
    (cond
      [(<= (string-length str) i) (list (substring str start i))]
      [(char=? (string-ref str i) ch)
       (cons (substring str start i) (loop (+ i 1) (+ i 1)))]
      [else (loop (+ i 1) start)])))

(define-syntax param-args
  (lambda (x)
    (syntax-case x ()
      [(_ arg-list-expr cases ...)
       #`(let loop ([args arg-list-expr])
           (if (null? args)
               '()
               (case (car args)
                 #,@(map (lambda (c)
                           (syntax-case c ()
                             [(#t case-expr func) #'(case-expr (func #t) (loop (cdr args)))]
                             [(#f case-expr func) #'(case-expr (func) (loop (cdr args)))]
                             [(case-expr func)
                              #'(case-expr
                                  (if (null? (cdr args))
                                      (errorf 'param-args "Missing required argument for ~a" 'case-expr))
                                  (func (cadr args))
                                  (loop (cddr args)))]))
                      #'(cases ...))
                   [else args])))])))

(define (printlns . args)
  (format #t "~{~a~n~}" args))

