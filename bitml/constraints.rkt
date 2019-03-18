#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/match csp
         "bitml.rkt" "terminals.rkt" "exp.rkt")

(provide (all-defined-out) make-csp add-var! add-constraint! solve)

(define constraints null)

(define (add-constraint constr)
  (set! constraints (cons constr constraints)))

(define-syntax (get-constr-tree stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred sum -> secret )

    #|
    [(_ (sum (split (val:number -> (~or (sum (contract params ...)...) (scontract sparams ...)))...))
        ((secret part:string ident:id hash:string) ...) (~optional parent))
     #'(get-constr-tree (sum (~? (scontract sparams ...))... (~? (contract params ...))... ...)
                        ((secret part ident hash) ...) (~? parent))]
|#
   
    ;entry point
    [(_ (sum (contract params ...)...)
        ((~or (secret part:string ident:id hash:string)
              (deposit p1 ...)
              (vol-deposit p2 ...)) ...)
        (~optional parent))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     (displayln #''(ident ...))

     (displayln #`'(begin
                     (get-constr-tree (contract params ...) ((secret part ident hash) ...) (~? parent))...
                     (when (or (constr-required? (contract params ...))...)
                       (~? (add-constraint (lambda y (and (parent #,@#'y) (not (and ((get-constr (contract params ...)) #,@#'y)...)))))
                           (add-constraint (lambda y (not (and ((get-constr (contract params ...)) #,@#'y)...))))))))
     
     
     #`(begin
         (get-constr-tree (contract params ...) ((secret part ident hash) ...) (~? parent))...
         (when (or (constr-required? (contract params ...))...)
           (~? (add-constraint (lambda y (and (parent #,@#'y) (not (and ((get-constr (contract params ...)) #,@#'y)...)))))
               (add-constraint (lambda y (not (and ((get-constr (contract params ...)) #,@#'y)...)))))))]
    
    [(_ (withdraw part:string) ((secret spart:string ident:id hash:string) ...) parent)
     #'(add-constraint parent)]
    
    [(_ (withdraw part:string) ((secret spart:string ident:id hash:string) ...))
     #'(values)]
    
    [(_ (after t (contract params ...)) ((secret part:string ident:id hash:string) ...) (~optional parent))
     #'(get-constr-tree (contract params ...) ((secret part ident hash)...) (~? parent))]
    
    [(_ (auth part:string ... (contract params ...)) ((secret spart:string ident:id hash:string) ...) (~optional parent))
     #'(get-constr-tree (contract params ...) ((secret part ident hash)...) (~? parent))]

            
    [(_ (split (val:number -> (sum (contract params ...)...)) ...)
        ((~or (secret part ident hash)
              (deposit p1 ...)
              (vol-deposit p2 ...)) ...)
        (~optional parent))
     #'(get-constr-tree (sum (contract params ...)... ...) ((secret part ident hash) ...) (~? parent))]

    [(_ (split (val:number -> (~or (sum (contract params ...)...) (scontract sparams ...)))...)
        ((secret part:string ident:id hash:string) ...) (~optional parent))
     #'(get-constr-tree (split (val -> (~? (sum (scontract sparams ...))) (~? (sum (contract params ...)...)) )...)
                        ((secret part ident hash)...) (~? parent))]

    

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...))
        ((secret part:string ident:id hash:string) ...)
        (~optional parent))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     (displayln #''(ident ...))
     #`(let ([maybe-parent (~? parent #t)]
             [maybe-pred (~? (compile-pred-constraint p ((secret part ident hash)...)) #t)])   
         (match (list maybe-parent maybe-pred)
           [(list #t #t)
            (get-constr-tree (contract params ...) ((secret part ident hash)...))]
           [(list x #t)
            (get-constr-tree (contract params ...) ((secret part ident hash)...))]
           [(list #t x)
            (get-constr-tree (contract params ...) ((secret part ident hash)...) (lambda y (x #,@#'y)))]
           [(list x1 x2)
            (get-constr-tree (contract params ...) ((secret part ident hash)...) (lambda y (and (x1 #,@#'y) (x2 #,@#'y))))]))]                              
             
    
    [(_ (reveal (sec:id ...) (contract params ...))
        ((secret part:string ident:id hash:string) ...)
        (~optional parent))
     #'(get-constr-tree (putrevealif () (sec ...) (contract params ...)) ((secret part ident hash)...) (~? parent))]

    [(_ (revealif (sec:id ...) (pred p) (contract params ...))
        ((secret part:string ident:id hash:string) ...) (~optional parent))
     #'(get-constr-tree (putrevealif () (sec ...) (pred p) (contract params ...)) ((secret part ident hash)...) (~? parent))]

    [(_ (reveal (tx:id ...) (contract params ...))
        ((secret part:string ident:id hash:string) ...)
        (~optional parent))
     #'(get-constr-tree (putrevealif (tx ...) () (contract params ...)) ((secret part ident hash)...) (~? parent))]))

;descends only a level in the syntax tree
(define-syntax (get-constr stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred sum strip-auth)
    
    [(_ (withdraw part:string) ((secret spart:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #'(lambda y #t)]
    
    [(_ (after t (contract params ...)) ((secret part:string ident:id hash:string) ...))
     #'(get-constr (contract params ...) ((secret part ident hash)...))]
    
    [(_ (auth part:string ... (contract params ...)) ((secret spart:string ident:id hash:string) ...))
     #'(get-constr (contract params ...) ((secret part ident hash)...))]

    [(_ (split (val:number -> (~or (sum (contract params ...)...) (scontract sparams ...)))...)
        ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #'(lambda y  (and (~? ((get-constr (scontract sparams ...) ((secret part ident hash)...)) #,@#'y))...
                       (~? ((get-constr (contract params ...) ((secret part ident hash)...)) #,@#'y))... ...))]

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...))
        ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #'(~? (compile-pred-constraint p ((secret part ident hash)...)) (lambda y #t))]

    [(_ (reveal (sec:id ...) (contract params ...))
        ((secret part:string ident:id hash:string) ...))
     #'(get-constr (putrevealif () (sec ...) (contract params ...))
                   ((secret part ident hash)...))]

    [(_ (revealif (sec:id ...) (pred p) (contract params ...))
        ((secret part:string ident:id hash:string) ...))
     #'(get-constr (putrevealif () (sec ...) (pred p) (contract params ...))
                   ((secret part ident hash)...))]

    [(_ (reveal (tx:id ...) (contract params ...))
        ((secret part:string ident:id hash:string) ...) parent)
     #'(get-constr (putrevealif (tx ...) () (contract params ...))
                   ((secret part ident hash)...))]))

(define-syntax (constr-required? stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred sum strip-auth)
    [(_ (withdraw part:string))
     #'#f]
    [(_ (after t (contract params ...)))
     #'(constr-required? (contract params ...))]
    [(_ (auth part:string ... (contract params ...)))
     #'(constr-required? (contract params ...))]

    [(_ (sum (contract params ...)...))       
     #'(or (constr-required? (contract params ...))...)]

    [(_ (split (val:number -> (~or (sum (contract params ...)...) (scontract sparams ...)))...))
     #'(or (~? (constr-required? (contract params ...)))... ... (~? (constr-required? (scontract sparams ...)))...)]

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (pred p) (contract params ...)))
     #'#t]

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (contract params ...)))
     #'#f]

    [(_ (reveal (sec:id ...) (contract params ...)))
     #'(constr-required? (putrevealif () (sec ...) (contract params ...)))]

    [(_ (revealif (sec:id ...) (pred p) (contract params ...)))
     #'(constr-required? (putrevealif () (sec ...) (pred p) (contract params ...)))]

    [(_ (reveal (tx:id ...) (contract params ...)) parent)
     #'(constr-required? (putrevealif (tx ...) () (contract params ...)))]))