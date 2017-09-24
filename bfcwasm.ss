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
  (Cmd (c)
       p
       m
       l
       r
       d
       (lb c0 c1 ... rb))
  (Prog
   (c0 c1 ...)))


(define (plus? o) (eq? '+ o))
(define (minus? o) (eq? '- o))
(define (left? o) (eq? '< o))
(define (right? o) (eq? '> o))
(define (dot? o) (eq? '. o))
(define (lbrack? o) (eq? 'lbrack o))
(define (rbrack? o) (eq? 'rbrack o))

  

