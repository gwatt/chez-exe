(library (os-info)
  (export os-name machine-bits name->linker-symbol)
  (import (chezscheme))

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

  (define (name->linker-symbol c-name)
    (case (os-name)
      [(linux) c-name]
      [(macosx) (format "_~a" c-name)]))

)
