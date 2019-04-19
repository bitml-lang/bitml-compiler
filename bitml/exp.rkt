#lang racket/base

(require (for-syntax racket/base syntax/parse)
         "env.rkt" "terminals.rkt")

(provide (all-defined-out)) 

;---------------------------------------------------------------------------------------
;methods used to transcompile predicates to balzac predicates
(define-syntax (compile-pred stx)
  (syntax-parse stx
    #:literals(btrue band bor bnot b= b< b<= b!= between)
    [(_ btrue) #'"true"]
    [(_ (band a b)) #'(string-append "(" (compile-pred a) " && " (compile-pred b) ")")]
    [(_ (bor a b)) #'(string-append "(" (compile-pred a) " || " (compile-pred b) ")")]
    [(_ (bnot a)) #'(string-append "!(" (compile-pred a) ")")]
    
    ;optimized compilation
    ;---------------------------------------------------------------------------
    [(_ (b= a:id b:id)) #'(string-append "size(" (symbol->string 'a) ") == size(" (symbol->string 'b) ")" )]
    [(_ (b!= a:id b:id)) #'(string-append "size(" (symbol->string 'a) ") != size(" (symbol->string 'b) ")" )]
    [(_ (b< a:id b:id)) #'(string-append "size(" (symbol->string 'a) ") < size(" (symbol->string 'b) ")" )]
    [(_ (b<= a:id b:id)) #'(string-append "size(" (symbol->string 'a) ") <= size(" (symbol->string 'b) ")" )]
    ;------------------------------------------------------------------------------
    
    [(_ (b= a b)) #'(string-append (compile-pred-exp a) "==" (compile-pred-exp b))]
    [(_ (b!= a b)) #'(string-append (compile-pred-exp a) "!=" (compile-pred-exp b))]
    [(_ (b< a b)) #'(string-append (compile-pred-exp a) "<" (compile-pred-exp b))]
    [(_ (b<= a b)) #'(string-append (compile-pred-exp a) "<=" (compile-pred-exp b))]
    [(_ (between a b c)) #'(string-append "between(" (compile-pred-exp a) "," (compile-pred-exp b) "," (compile-pred-exp c) ")")]))

(define-syntax (compile-pred-exp stx)
  (syntax-parse stx
    #:literals(b+ b- bsize)
    [(_ (b+ a b)) #'(string-append "(" (compile-pred-exp a) "+" (compile-pred-exp b) ")")]
    [(_ (b- a b)) #'(string-append "(" (compile-pred-exp a) "-" (compile-pred-exp b) ")")]
    [(_ a:id) #'(string-append "(size(" (symbol->string 'a) ") - " (number->string sec-param) ")")]
    [(_ a:number) #'(number->string a)]
    [(_) (raise-syntax-error #f "wrong if predicate" stx)]))


;---------------------------------------------------------------------------------------
;methods used to transcompile predicates to maude predicates
(define-syntax (compile-pred-maude stx)
  (syntax-parse stx
    #:literals(btrue band bor bnot b= b< b<= b!= between)
    [(_ btrue) #'"True"]
    [(_ (band a b)) #'(string-append "(" (compile-pred-maude a) " && " (compile-pred-maude b) ")")]
    [(_ (bor a b)) #'(string-append "(" (compile-pred-maude a) " || " (compile-pred-maude b) ")")]
    [(_ (bnot a)) #'(string-append "!(" (compile-pred-maude a) ")")]
    [(_ (b= a b)) #'(string-append (compile-pred-exp-maude a) " == " (compile-pred-exp-maude b))]
    [(_ (b!= a b)) #'(string-append (compile-pred-exp-maude a) " != " (compile-pred-exp-maude b))]
    [(_ (b< a b)) #'(string-append (compile-pred-exp-maude a) " < " (compile-pred-exp-maude b))]
    [(_ (b<= a b)) #'(string-append (compile-pred-exp-maude a) " <= " (compile-pred-exp-maude b))]
    [(_ (between a b c)) #'(string-append "((" (compile-pred-exp-maude a) " >= " (compile-pred-exp-maude b) ") && "
                                          "(" (compile-pred-exp-maude a) " <= " (compile-pred-exp-maude c) "))")]))

(define-syntax (compile-pred-exp-maude stx)
  (syntax-parse stx
    #:literals(b= b< b<= b+ b- bsize)
    [(_ (b+ a b)) #'(string-append "(" (compile-pred-exp-maude a) " + " (compile-pred-exp-maude b) ")")]
    [(_ (b- a b)) #'(string-append "(" (compile-pred-exp-maude a) " - " (compile-pred-exp-maude b) ")")]
    [(_ a:id) #'(string-append "size(" (symbol->string 'a) ")")]
    [(_ a:number) #'(string-append "const(" (number->string a) ")")]
    [(_) (raise-syntax-error #f "wrong if predicate" stx)]))

;---------------------------------------------------------------------------------------
;methods used to compile preditcates contraints for constraint solving
(define-syntax (compile-pred-constraint stx)
  (syntax-parse stx
    #:literals(btrue band bor bnot b= b< b<= b!= between)
    
    [(_ btrue ((secret part:string ident:id hash:string) ...))
     #'#t]
    
    [(_ (band p1 p2) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y
         (and ((compile-pred-constraint p1 ((secret part ident hash)...)) #,@#'y)
              ((compile-pred-constraint p2 ((secret part ident hash)...)) #,@#'y)))]
    
    [(_ (bor p1 p2) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y (or
                  ((compile-pred-constraint p1 ((secret part ident hash)...)) #,@#'y)
                  ((compile-pred-constraint p2 ((secret part ident hash)...)) #,@#'y)))]
    
    [(_ (bnot p1) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y (not ((compile-pred-constraint p1 ((secret part ident hash)...)) #,@#'y)))]
    
    [(_ (b= p1 p2) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y (= ((compile-pred-exp-contraint p1 ((secret part ident hash)...)) #,@#'y)
                    ((compile-pred-exp-contraint p2 ((secret part ident hash)...)) #,@#'y)))]
    
    [(_ (b!= p1 p2) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y (not (=
                       ((compile-pred-exp-contraint p1 ((secret part ident hash)...)) #,@#'y)
                       ((compile-pred-exp-contraint p2 ((secret part ident hash)...)) #,@#'y))))]
    
    [(_ (b< p1 p2) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...))) 
     #`(lambda y (< ((compile-pred-exp-contraint p1 ((secret part ident hash)...)) #,@#'y)
                    ((compile-pred-exp-contraint p2 ((secret part ident hash)...)) #,@#'y)))]
    
    [(_ (b<= p1 p2) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y (<= ((compile-pred-exp-contraint p1 ((secret part ident hash)...)) #,@#'y)
                     ((compile-pred-exp-contraint p2 ((secret part ident hash)...)) #,@#'y)))]
    [(_ (between p1 p2 p3) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y (<= ((compile-pred-exp-contraint p2 ((secret part ident hash)...)) #,@#'y)
                     ((compile-pred-exp-contraint p1 ((secret part ident hash)...)) #,@#'y)
                     ((compile-pred-exp-contraint p3 ((secret part ident hash)...)) #,@#'y)))]))

(define-syntax (compile-pred-exp-contraint stx)
  (syntax-parse stx
    #:literals(b+ b- bsize)
    [(_ (b+ p1 p2) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y
         (+ ((compile-pred-exp-contraint p1 ((secret part ident hash)...)) #,@#'y)
            ((compile-pred-exp-contraint p2 ((secret part ident hash)...)) #,@#'y)))]
    
    [(_ (b- p1 p2) ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y (- ((compile-pred-exp-contraint p1 ((secret part ident hash)...)) #,@#'y)
                    ((compile-pred-exp-contraint p2 ((secret part ident hash)...)) #,@#'y)))]
    
    [(_ x:id ((secret part:string ident:id hash:string) ...))
     #:with p (datum->syntax #'f (syntax->list #'(ident ...)))
     ;#:with y (datum->syntax #'f (syntax-e #'x))

     (let* ([idents (syntax->list #'(ident ...))]
            [q (syntax-e #'x)]
            [y (datum->syntax #'f (findf (lambda (s) (eq? (syntax-e s) q)) idents))])

       #`(lambda p #,y))]
    
    [(_ n:number ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #'(lambda y n)]
    
    [(_) (raise-syntax-error #f "wrong if predicate" stx)]))