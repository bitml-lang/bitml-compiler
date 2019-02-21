#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/list racket/port racket/system racket/match racket/string
         "bitml.rkt" "string-helpers.rkt" "env.rkt" "terminals.rkt" "exp.rkt")

(provide (all-defined-out))

(define constraints null)

(define (add-constraint constr)
  (set! constraints (append constraints constr)))

(define-syntax (get-constr-tree stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred sum strip-auth)

    ;entry point
    [(_ (sum (contract params ...)...) (~optional parent))
     #'(begin
         (get-constr-tree (contract params ...) (~? parent))...
         (when (or (not (equal? (get-constr (contract params ...)) #t))...)
           (~? (add-constraint (list (list 'and parent (list 'not (list 'yand (get-constr (contract params ...))...))))))
               (add-constraint (list (list 'not (list 'and (get-constr (contract params ...))...))))))]

    [(_ (withdraw part:string) parent)
     #'(add-constraint (list parent))]
    [(_ (withdraw part:string))
     #'(values)]
    
    [(_ (after t (contract params ...)) (~optional parent))
     #'(get-constr-tree (contract params ...) (~? parent))]
    
    [(_ (auth part:string ... (contract params ...)) (~optional parent))
     #'(get-constr-tree (contract params ...) (~? parent))]
    
    [(_ (split (val:number -> (contract params ...))... ) (~optional parent))
     #'(begin
         (get-constr-tree (contract params ...) (~? parent))...
         (when (or (not (equal? (get-constr (contract params ...)) #t))...)
           (add-constraint (list 'and (~? parent) (list 'not (list 'and (get-constr (contract params ...))...))))))]

    

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...)) (~optional parent))
    
     #'(let ([maybe-parent (~? parent #t)]
             [maybe-pred (~? (compile-pred-constraint p) #t)])
         (match (list maybe-parent maybe-pred)
           [(list #t #t)
            (get-constr-tree (contract params ...))]
           [(list x #t)
            (get-constr-tree (contract params ...))]
           [(list #t x)
            (get-constr-tree (contract params ...) x)]
           [(list a b)
            (get-constr-tree (contract params ...) (list 'and a b))]))]                                
                                
             
    
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
     #'#t]
    [(_ (after t (contract params ...)))
     #'(get-constr (contract params ...))]
    [(_ (auth part:string ... (contract params ...)))
     #'(get-constr (contract params ...))]

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...)))
     #'(~? (compile-pred-constraint p) #t)]

    [(_ (reveal (sec:id ...) (contract params ...)))
     #'(get-constr (putrevealif () (sec ...) (contract params ...)))]

    [(_ (revealif (sec:id ...) (pred p) (contract params ...)))
     #'(get-constr (putrevealif () (sec ...) (pred p) (contract params ...)))]

    [(_ (reveal (tx:id ...) (contract params ...)) parent)
     #'(get-constr (putrevealif (tx ...) () (contract params ...)))]))