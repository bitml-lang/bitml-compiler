#lang racket/base

(require (for-syntax racket/base syntax/parse racket/syntax)
         racket/match csp
         "bitml.rkt" "terminals.rkt" "exp.rkt" "env.rkt")

(provide (all-defined-out) make-csp add-var! add-constraint! solve)

(define constraints null)

(define (add-constraint constr)
  (set! constraints (cons constr constraints)))

(define-syntax (get-constraints* stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred sum ->)

    [(_ (sum (split (val:number -> (~or (sum (contract params ...)...) (scontract sparams ...)))...)) (var:id ...) (~optional parent))
     #'(get-constraints* (sum (~? (scontract sparams ...))... (~? (contract params ...))... ...) (~? parent))]
   
    ;entry point
    [(_ (sum (contract params ...)...) (var:id ...) (~optional parent))
     #'(begin
         (get-constraints* (contract params ...) (var ...) (~? parent))...
         (when (or (constr-required? (contract params ...))...)
           (~? (add-constraint (lambda (var ...) (and (parent var ...) (not (and ((get-constr (contract params ...)) var ...)...)))))
               (add-constraint (lambda (var ...) (not (and ((get-constr (contract params ...)) var ...)...)))))))]
    
    [(_ (withdraw part:string) (var:id ...) parent)
     #'(add-constraint parent)]
    
    [(_ (withdraw part:string) (var:id ...))
     #'(values)]
    
    [(_ (after t (contract params ...)) (var:id ...) (~optional parent))
     #'(get-constraints* (contract params ...) (var ...) (~? parent))]
    
    [(_ (auth part:string ... (contract params ...)) (var:id ...) (~optional parent))
     #'(get-constraints* (contract params ...) (var ...) (~? parent))]

            
    [(_ (split (val:number -> (~or (sum (contract params ...)...) (scontract sparams ...)))...) (var:id ...) (~optional parent))
     #'(get-constraints* (sum (~? (scontract sparams ...))... (~? (contract params ...))... ...) (~? parent))]

    

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...)) (var:id ...) (~optional parent))
     (with-syntax ([(arg ... ) (datum->syntax this-syntax (syntax->list #'(var ...))) ])
       #'(let ([maybe-parent (~? parent #t)]
               [maybe-pred (~? (compile-pred-constraint p) #t)])   
           (match (list maybe-parent maybe-pred)
             [(list #t #t)
              (get-constraints* (contract params ...) (var ...))]
             [(list x #t)
              (get-constraints* (contract params ...) (var ...))]
             [(list #t x)
              (get-constraints* (contract params ...) (var ...) (lambda var ... (x var ...)))]
             [(list x y)
              (get-constraints* (contract params ...) (var ...)
                                (lambda (var ...) (and (x var ...) (y var ...)))
                                )]))

       )
     ]                              
             
    
    [(_ (reveal (sec:id ...) (contract params ...)) (var:id ...) (~optional parent))
     #'(get-constraints* (putrevealif () (sec ...) (contract params ...)) (var ...) (~? parent))]

    [(_ (revealif (sec:id ...) (pred p) (contract params ...)) (var:id ...) (~optional parent))
     #'(get-constraints* (putrevealif () (sec ...) (pred p) (contract params ...)) (var ...) (~? parent))]

    [(_ (reveal (tx:id ...) (contract params ...)) (var:id ...) (~optional parent))
     #'(get-constraints* (putrevealif (tx ...) () (contract params ...)) (var ...) (~? parent))]))

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

(define-syntax (get-constraints stx)
  (syntax-parse stx
    [(_ x (id))
     (with-syntax ([var (datum->syntax stx (syntax-e #'id))])
       (displayln #''(get-constraints* x (var)))
       #'(get-constraints* x (var)))]))