;; bfcwasm.ss

(import (rnrs) (nanopass))

(define-language bfast
  (terminals
   (plus (p))
   (minus (m))
   (left (l))
   (right (r))
   (dot (d))
   (lbrack (lb))
   (rbrack (rb)))
  (entry Prog)
  (Cmd (c)
       p
       m
       l
       r
       d
       (lb c0 c1 ... rb))
  (Prog (P)
        (c0 c1 ...)))


(define (plus? o) (eqv? #\+ o))
(define (minus? o) (eqv? #\- o))
(define (left? o) (eqv? #\< o))
(define (right? o) (eqv? #\> o))
(define (dot? o) (eqv? #\. o))
(define (lbrack? o) (eqv? #\[ o))
(define (rbrack? o) (eqv? #\] o))

(define-parser sexp->bfast bfast)

(define (parse p)
  (sexp->bfast (string->list p)))  ; TODO check brackets
