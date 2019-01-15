#lang racket/base

(require (for-syntax racket/base syntax/parse) "env.rkt" "terminals.rkt")
 

(define-syntax (compile-pred stx)
  (syntax-parse stx
    #:literals(btrue band bnot)
    [(_ btrue) #'"true"]
    [(_ (band a b)) #'(string-append (compile-pred a) " && " (compile-pred b))]
    [(_ (bnot a)) #'(string-append "!(" (compile-pred a) ")")]
    [(_ p) #'(compile-pred-exp p)]))

(define-syntax (compile-pred-maude stx)
  (syntax-parse stx
    #:literals(btrue band bnot)
    [(_ btrue) #'"True"]
    [(_ (band a b)) #'(string-append (compile-pred-maude a) " && " (compile-pred-maude b))]
    [(_ (bnot a)) #'(string-append "!(" (compile-pred-maude a) ")")]
    [(_ p) #'(compile-pred-exp-maude p)]))


(define-syntax (compile-pred-exp stx)
  (syntax-parse stx
    #:literals(b= b< b<= b+ b- bsize)
    [(_ (b= a b)) #'(string-append (compile-pred-exp a) "==" (compile-pred-exp b))]
    [(_ (b< a b)) #'(string-append (compile-pred-exp a) "<" (compile-pred-exp b))]
    [(_ (b<= a b)) #'(string-append (compile-pred-exp a) "<=" (compile-pred-exp b))]
    [(_ (b+ a b)) #'(string-append "(" (compile-pred-exp a) "+" (compile-pred-exp b) ")")]
    [(_ (b- a b)) #'(string-append "(" (compile-pred-exp a) "-" (compile-pred-exp b) ")")]
    [(_ (bsize a)) #'(string-append "(size(" (compile-pred-exp a) ") - " (number->string sec-param) ")")]
    [(_ a:number) #'(number->string a)]
    [(_ a:string) #'a]
    [(_ a:id) #'(symbol->string 'a)]
    [(_) (raise-syntax-error #f "wrong if predicate" stx)]))

(define-syntax (compile-pred-exp-maude stx)
  (syntax-parse stx
    #:literals(b= b< b<= b+ b- bsize)
    [(_ (b= a b)) #'(string-append (compile-pred-exp-maude a) " == " (compile-pred-exp-maude b))]
    [(_ (b< a b)) #'(string-append (compile-pred-exp-maude a) " < " (compile-pred-exp-maude b))]
    [(_ (b<= a b)) #'(string-append (compile-pred-exp-maude a) " <= " (compile-pred-exp-maude b))]
    [(_ (b+ a b)) #'(string-append "(" (compile-pred-exp-maude a) " + " (compile-pred-exp-maude b) ")")]
    [(_ (b- a b)) #'(string-append "(" (compile-pred-exp-maude a) " - " (compile-pred-exp-maude b) ")")]
    [(_ (bsize a)) #'(string-append "| " (compile-pred-exp-maude a) " |")]
    [(_ a:number) #'(string-append "const(" (number->string a) ")")]
    [(_ a:string) #'(string-append "const(" a ")")]
    [(_ a:id) #'(string-append "ref(" (symbol->string 'a) ")")]
    [(_) (raise-syntax-error #f "wrong if predicate" stx)]))

(provide (all-defined-out))