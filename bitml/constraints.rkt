#lang racket/base

(require (for-syntax racket/base syntax/parse racket/list)
         racket/list racket/match csp
         "bitml.rkt" "terminals.rkt" "exp.rkt")

(provide (all-defined-out) make-csp add-var! add-constraint! solve)

(define constraints null)

(define (add-constraint constr)
  (set! constraints (cons constr constraints)))

(define-syntax (get-secrets-lengths stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred choice -> secret )
    [(_ (choice (contract params ...) ...)
        ((~or (secret part:string ident:id hash:string)
              (deposit p1 ...)
              (vol-deposit p2 ...)) ...))
     
     (if (constr-tree-required? #''(choice (contract params ...)...))      

         #'(begin
             (displayln "constr required")
             (get-constr-tree (choice (contract params ...)...) ((secret part ident hash) ...))

             (let* ([secret-list-with-f 
                    (remove-duplicates
                     (for/list ([constr constraints])
                       (begin
                         (define prob (make-csp))
                         (add-var! prob 'ident (range 0 100))...

                         (add-constraint! prob constr '(ident ...))
                         (solve prob))))]
                   [secret-list (filter (lambda (x) x) secret-list-with-f)])

               ;if no constraints were imposed, add default values
               (when (= 0 (length secret-list))
                 (set! secret-list (list (list (cons 'ident 1)...))))

               (displayln secret-list)

               ;convert each list in a map
               ;output will be a list of maps
               (for/list ([secrets secret-list])
                 (foldr (lambda (x m) (hash-set m (car x) (cdr x))) (make-immutable-hash) secrets))))

         #'(begin
             (displayln "constr not required")
             ;if no constraints were imposed, add default values
             (let ([secret-list (list (list (cons 'ident 1)...))])
               (displayln secret-list)

               ;convert each list in a map
               ;output will be a list of maps
               (for/list ([secrets secret-list])
                 (foldr (lambda (x m) (hash-set m (car x) (cdr x))) (make-immutable-hash) secrets)))))]))

(define-syntax (get-constr-tree stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred choice -> secret put reveal revealif tau)

    #|
    [(_ (choice (split (val:number -> (~or (choice (contract params ...)...) (scontract sparams ...)))...))
        ((secret part:string ident:id hash:string) ...) (~optional parent))
     #'(get-constr-tree (choice (~? (scontract sparams ...))... (~? (contract params ...))... ...)
                        ((secret part ident hash) ...) (~? parent))]
|#
   
    ;entry point with secrets
    [(_ (choice (contract params ...)...)
        ((~or (secret part:string ident:id hash:string)
              (deposit p1 ...)
              (vol-deposit p2 ...)) ...)
        (~optional parent))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     
     #`(begin
         (get-constr-tree (contract params ...) ((secret part ident hash) ...) (~? parent))...

         (when (or (constr-required? (contract params ...))...)
           (add-constraint (lambda y (and (~? (parent #,@#'y) #t)
                                          (and (not ((get-constr (contract params ...) ((secret part ident hash) ...)) #,@#'y))...)))))
         
         ;;(when (constr-required? (contract params ...))
         ;;(add-constraint (lambda y (and (~? (parent #,@#'y) #t) (not ((get-constr (contract params ...) ((secret part ident hash) ...)) #,@#'y))))))...
         )]

    ;entry point without secrets
    [(_ (choice (contract params ...)...)
        ((~or (deposit p1 ...)
              (vol-deposit p2 ...)) ...)
        (~optional parent))
     #'(get-constr-tree (choice (contract params ...)...) (secret "A" a "a") (~? parent))]
    
    [(_ (withdraw part:string) ((secret spart:string ident:id hash:string) ...) parent)
     #'(begin
         (add-constraint parent))]
    
    [(_ (withdraw part:string) ((secret spart:string ident:id hash:string) ...))
     #'(values)]
    
    [(_ (after t (contract params ...)) ((secret part:string ident:id hash:string) ...) (~optional parent))
     #'(get-constr-tree (contract params ...) ((secret part ident hash)...) (~? parent))]
    
    [(_ (auth part:string ... (contract params ...)) ((secret spart:string ident:id hash:string) ...) (~optional parent))
     #'(get-constr-tree (contract params ...) ((secret part ident hash)...) (~? parent))]

            
    [(_ (split (val:number -> (choice (contract params ...)...)) ...)
        ((~or (secret part ident hash)
              (deposit p1 ...)
              (vol-deposit p2 ...)) ...)
        (~optional parent))
     #'(begin
         (get-constr-tree (choice (contract params ...)...) ((secret part ident hash) ...) (~? parent))...)]

    [(_ (split (val:number -> (~or (choice (contract params ...)...) (scontract sparams ...)))...)
        ((secret part:string ident:id hash:string) ...) (~optional parent))
     #'(get-constr-tree (split (val -> (~? (choice (scontract sparams ...))) (~? (choice (contract params ...)...)) )...)
                        ((secret part ident hash)...) (~? parent))]

    

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...))
        ((secret part:string ident:id hash:string) ...)
        (~optional parent))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
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

    [(_ (put (tx:id ...) (contract params ...))
        ((secret part:string ident:id hash:string) ...)
        (~optional parent))
     #'(get-constr-tree (putrevealif (tx ...) () (contract params ...)) ((secret part ident hash)...) (~? parent))]

    [(_ (tau (contract params ...))
        ((secret part:string ident:id hash:string) ...)
        (~optional parent))
     #'(get-constr-tree (putrevealif () () (contract params ...)) ((secret part ident hash)...) (~? parent))]))

;descends only a level in the syntax tree
(define-syntax (get-constr stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred choice strip-auth put reveal revealif tau)
    
    [(_ (withdraw part:string) ((secret spart:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #'(lambda y #t)]
    
    [(_ (after t (contract params ...)) ((secret part:string ident:id hash:string) ...))
     #'(get-constr (contract params ...) ((secret part ident hash)...))]
    
    [(_ (auth part:string ... (contract params ...)) ((secret spart:string ident:id hash:string) ...))
     #'(get-constr (contract params ...) ((secret part ident hash)...))]
    
    #;[(_ (split (val:number -> (scontract sparams ...))...)
          ((secret part:string ident:id hash:string) ...))
       #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
       #`(lambda y  (and ((get-constr (scontract sparams ...) ((secret part ident hash)...)) #,@#'y)...))]

    #;[(_ (split (val:number -> (~or (choice (contract params ...)...) (scontract sparams ...)))...)
          ((secret part:string ident:id hash:string) ...))
       #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
       #`(lambda y  (and (~? ((get-constr (scontract sparams ...) ((secret part ident hash)...)) #,@#'y))...
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

    [(_ (put (tx:id ...) (contract params ...))
        ((secret part:string ident:id hash:string) ...))
     #'(get-constr (putrevealif (tx ...) () (contract params ...))
                   ((secret part ident hash)...))]

    [(_ (tau (contract params ...))
        ((secret part:string ident:id hash:string) ...))
     #'(get-constr (putrevealif () () (contract params ...))
                   ((secret part ident hash)...))]
    [(_ any-contract
        ((secret part:string ident:id hash:string) ...))
     #:with y (datum->syntax #'f (syntax->list #'(ident ...)))
     #`(lambda y  #t)]))

(define-syntax (constr-required? stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred choice strip-auth put reveal revealif tau)
    [(_ (withdraw part:string))
     #'#f]
    [(_ (after t (contract params ...)))
     #'(constr-required? (contract params ...))]
    [(_ (auth part:string ... (contract params ...)))
     #'(constr-required? (contract params ...))]
    [(_ (choice (contract params ...)...))       
     #'#f]
    [(_ (split (val:number ->(scontract sparams ...))...))
     #'#f]
    [(_ (split (val:number -> (~or (choice (contract params ...)...) (scontract sparams ...)))...))
     #'#f]
    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (pred p) (contract params ...)))
     #'#t]
    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (contract params ...)))
     #'#f]
    [(_ (reveal (sec:id ...) (contract params ...)))
     #'#f]
    [(_ (revealif (sec:id ...) (pred p) (contract params ...)))
     #'#t]
    [(_ (put (tx:id ...) (contract params ...)))
     #'#f]
    [(_ (tau (contract params ...)))
     #'#f]))

(begin-for-syntax
  (define (constr-tree-required? stx)
    (let ([stx-lst (flatten (syntax->datum stx))])
      (not (equal? #f (member 'pred stx-lst))))))
