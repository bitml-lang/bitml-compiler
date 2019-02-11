#lang rosette

(require (for-syntax racket/base syntax/parse)
         racket/list racket/port racket/system racket/match racket/string
         "bitml.rkt" "string-helpers.rkt" "env.rkt" "terminals.rkt" "exp.rkt")

(provide (all-defined-out))

(define constraints null)

(define-syntax (get-constr-tree stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred sum strip-auth)
    [(_ (withdraw part:string))
     #'#t]
    [(_ (after t (contract params ...)))
     #'(get-constr-tree (contract params ...))]
    [(_ (auth part:string ... (contract params ...)))
     #'(get-constr-tree (contract params ...))]
    
    [(_ (split (val:number -> (contract params ...))... ))
     #'(list (get-constr-tree (contract params ...))...)]

    [(_ (sum (contract params ...)...))
     #'(list (get-constr-tree (contract params ...))...)]

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...)))
     #'(list (~? (compile-pred-constraint p) #t)
             (get-constr-tree (contract params ...)))]

    [(_ (reveal (sec:id ...) (contract params ...)))
     #'(get-constr-tree (putrevealif () (sec ...) (contract params ...)))]

    [(_ (revealif (sec:id ...) (pred p) (contract params ...)))
     #'(get-constr-tree (putrevealif () (sec ...) (pred p) (contract params ...)))]

    [(_ (reveal (tx:id ...) (contract params ...)))
     #'(get-constr-tree (putrevealif (tx ...) () (contract params ...)))]))