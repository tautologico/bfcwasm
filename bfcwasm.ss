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

(define commands (list #\+ #\- #\< #\> #\. #\[ #\]))

(define (command? c) (memv c commands))

(define (parse-prog b)
  (define (parse-loop l acc)
    (cond [(null? l) (error 'parse "unclosed loop")]
          [(eqv? #\] (car l)) (values (cdr l) (reverse (cons #\] acc)))] 
          [(eqv? #\[ (car l))
           (let-values ([(rest res) (parse-loop (cdr l) (list (car l)))])
             (parse-loop rest (cons res acc)))]
          [else (parse-loop (cdr l) (cons (car l) acc))]))
  (cond [(null? b) b]
        [(eqv? #\[ (car b))
         (let-values ([(rest res) (parse-loop (cdr b) (list (car b)))])
           (cons res (parse-prog rest)))]
        [else (cons (car b) (parse-prog (cdr b)))]))

;; Parse a bf program represented as a string,
;; producing a record in the bfast language. 
;; As is standard in bf programs, any character that is not a
;; valid command is considered to be part of a comment and is
;; filtered out.
(define (parse p)
  (sexp->bfast
   (parse-prog
    (filter command? (string->list p)))))

(define-pass gen-wasm : bfast (p) -> * ()
  (definitions
    (define (emit-plus)  (printf "(incr-reg)\n"))
    (define (emit-minus) (printf "(decr-reg)\n"))
    (define (emit-left)  (printf "(incr-counter)\n"))
    (define (emit-right) (printf "(decr-counter)\n"))
    (define (emit-dot) (printf "(output-char)\n"))
    (define (emit-loop) (printf "loop!\n")))
  (Cmd : Cmd (c) -> * ()
       [,p (emit-plus)]
       [,m (emit-minus)]
       [,l (emit-left)]
       [,r (emit-right)]
       [,d (emit-dot)]
       [(,lb ,c0 ,c1* ... ,rb) (emit-loop)])
  (Prog : Prog (p) -> * ()
        [(,c0 ,c1* ...)
         (Cmd c0)
         (for-each Cmd c1*)])
  (Prog p))
