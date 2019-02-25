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
    #:literals (withdraw after auth split putrevealif pred sum ->)

    [(_ (sum (split (val:number -> (~or (sum (contract params ...)...) (scontract sparams ...)))...)) (~optional parent))
     #'(get-constr-tree (sum (~? (scontract sparams ...))... (~? (contract params ...))... ...) (~? parent))]
   
    ;entry point
    [(_ (sum (contract params ...)...) (~optional parent))          
     #'(begin
         (get-constr-tree (contract params ...) (~? parent))...
         (when (or (constr-required? (contract params ...))...)
           (~? (add-constraint (lambda (a b) (and (parent a b) (not (and ((get-constr (contract params ...)) a b)...)))))
               (add-constraint (lambda (a b) (not (and ((get-constr (contract params ...)) a b)...)))))))]
    
    [(_ (withdraw part:string) parent)
     #'(add-constraint parent)]
    
    [(_ (withdraw part:string))
     #'(values)]
    
    [(_ (after t (contract params ...)) (~optional parent))
     #'(get-constr-tree (contract params ...) (~? parent))]
    
    [(_ (auth part:string ... (contract params ...)) (~optional parent))
     #'(get-constr-tree (contract params ...) (~? parent))]

            
    [(_ (split (val:number -> (~or (sum (contract params ...)...) (scontract sparams ...)))...) (~optional parent))
     #'(get-constr-tree (sum (~? (scontract sparams ...))... (~? (contract params ...))... ...) (~? parent))]

    

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...)) (~optional parent))    
     #'(let ([maybe-parent (~? parent #t)]
             [maybe-pred (~? (compile-pred-constraint p) #t)])   
         (match (list maybe-parent maybe-pred)
           [(list #t #t)
            (get-constr-tree (contract params ...))]
           [(list x #t)
            (get-constr-tree (contract params ...))]
           [(list #t x)
            (get-constr-tree (contract params ...) (lambda (a b) (x a b)))]
           [(list x y)
            (get-constr-tree (contract params ...) (lambda (a b) (and (x a b) (y a b))))]))]                              
             
    
    [(_ (reveal (sec:id ...) (contract params ...)) (~optional parent))
     #'(get-constr-tree (putrevealif () (sec ...) (contract params ...)) (~? parent))]

    [(_ (revealif (sec:id ...) (pred p) (contract params ...)) (~optional parent))
     #'(get-constr-tree (putrevealif () (sec ...) (pred p) (contract params ...)) (~? parent))]

    [(_ (reveal (tx:id ...) (contract params ...)) (~optional parent))
     #'(get-constr-tree (putrevealif (tx ...) () (contract params ...)) (~? parent))]))

;descends only a level in the syntax tree
(define-syntax (get-constr stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred sum strip-auth)
    [(_ (withdraw part:string))
     #'(lambda (a b) #t)]
    [(_ (after t (contract params ...)))
     #'(get-constr (contract params ...))]
    [(_ (auth part:string ... (contract params ...)))
     #'(get-constr (contract params ...))]

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...)))
     #'(~? (compile-pred-constraint p) (lambda (a b) #t))]

    [(_ (reveal (sec:id ...) (contract params ...)))
     #'(get-constr (putrevealif () (sec ...) (contract params ...)))]

    [(_ (revealif (sec:id ...) (pred p) (contract params ...)))
     #'(get-constr (putrevealif () (sec ...) (pred p) (contract params ...)))]

    [(_ (reveal (tx:id ...) (contract params ...)) parent)
     #'(get-constr (putrevealif (tx ...) () (contract params ...)))]))

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