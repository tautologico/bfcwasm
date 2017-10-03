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

(define (parse-file fname)
  (call-with-port (open-file-input-port fname (file-options) (buffer-mode block) (native-transcoder))
                  (lambda (port)
                    (parse (get-string-all port)))))

;; TODO improve on printf to emit code; improve emitted code
(define-pass gen-wasm : bfast (p) -> * ()
  (definitions
    (define (emit-boilerplate)
      (printf "(module\n")
      (printf "  (import \"console\" \"writech\" (func $writech (param i32)))\n")
      (printf "  (global $i (mut i32) (i32.const 0))\n")
      (printf "  (memory $mem 1)\n")
      (printf "  (func $incrindex\n")
      (printf "    get_global $i\n")
      (printf "    i32.const 4\n")
      (printf "    i32.add\n")
      (printf "    set_global $i)\n")
      (printf "\n")
      (printf "  (func $decrindex\n")
      (printf "    get_global $i\n")
      (printf "    i32.const 4\n")
      (printf "    i32.sub\n")
      (printf "    set_global $i)\n")
      (printf "\n")
      (printf "  (func (export \"getindex\") (result i32)\n")
      (printf "    get_global $i)\n")
      (printf "\n")
      (printf "  (func $incracc\n")
      (printf "    get_global $i\n")
      (printf "    get_global $i\n")
      (printf "    i32.load\n")
      (printf "    i32.const 1\n")
      (printf "    i32.add\n")
      (printf "    i32.store)\n")
      (printf "\n")
      (printf "  (func $decracc\n")
      (printf "    get_global $i\n")
      (printf "    get_global $i\n")
      (printf "    i32.load    \n")
      (printf "    i32.const 1\n")
      (printf "    i32.sub\n")
      (printf "    i32.store)\n")
      (printf "\n")
      (printf "  (func (export \"program\")\n"))
    (define (emit-plus)  (printf "    call $incracc\n"))
    (define (emit-minus) (printf "    call $decracc\n"))
    (define (emit-left)  (printf "    call $decrindex\n"))
    (define (emit-right) (printf "    call $incrindex\n"))
    (define (emit-dot)
      (printf "    get_global $i\n")
      (printf "    i32.load\n")
      (printf "    call $writech\n"))
    (define (emit-loop c0 c1*)
      (define exit-label (format "$~a" (gensym)))
      (define loop-label (format "$~a" (gensym)))
      (printf "    block ~a\n" exit-label)
      (printf "    get_global $i\n")
      (printf "    i32.load\n")
      (printf "    i32.eqz\n")
      (printf "    br_if ~a\n" exit-label)
      (printf "    loop ~a\n" loop-label)
      (Cmd c0)
      (for-each Cmd c1*)
      (printf "    get_global $i\n")
      (printf "    i32.load\n")
      (printf "    br_if ~a\n" loop-label)
      (printf "    end ~a\n" loop-label)
      (printf "    end ~a\n" exit-label)))
  (Cmd : Cmd (c) -> * ()
       [,p (emit-plus)]
       [,m (emit-minus)]
       [,l (emit-left)]
       [,r (emit-right)]
       [,d (emit-dot)]
       [(,lb ,c0 ,c1* ... ,rb) (emit-loop c0 c1*)])
  (Prog : Prog (p) -> * ()
        [(,c0 ,c1* ...)
         (emit-boilerplate)
         (Cmd c0)
         (for-each Cmd c1*)
         (printf "))\n")])
  (Prog p))

(define (compile-file fname)
  (gen-wasm (parse-file fname)))
