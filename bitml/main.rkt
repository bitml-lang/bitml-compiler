#lang racket/base

(require (for-syntax racket/base syntax/parse) syntax/to-string
         "bitml.rkt" "maude.rkt" "string-helpers.rkt" "env.rkt" "terminals.rkt" "constraints.rkt")

;provides the default reader for an s-exp lang
(module reader syntax/module-reader
  bitml)

(provide  participant compile withdraw deposit guards
          after auth key secret vol-deposit putrevealif
          put reveal revealif
          pred sum split generate-keys ->
          (rename-out [btrue true] [band and] [bnot not] [b= =] [b!= !=] [b< <] [b+ +] [b- -] [b<= <=] [bsize size])
          strategy b-if do-reveal do-auth not-destory do-destory
          state check-liquid check has-more-than 
          #%module-begin #%datum #%top-interaction)
   
;compilation command
(define-syntax (compile stx)
  (syntax-parse stx
    #:literals (guards sum)
    [(_ (guards guard ...)
        (sum (contract params ...) ...)
        maude-query ...)
    
     
     #`(begin
         (reset-state)
         guard ...

         (let* ([scripts-list (list (get-script (contract params ...)) ...)]
                [script (list+sep->string scripts-list " || ")]
                [script-params (get-script-params (sum (contract params ...) ...))])

           (compile-init parts deposit-txout tx-v script script-params)


           ;start the compilation of the continuation contracts
           (contract params ... '(sum (contract params ...)...) "Tinit" 0 tx-v (get-participants) 0 (get-script-params (contract params ...)) script-params)...

           (displayln (get-constr-tree (sum (contract params ...)...)))
           
           ;start the maude code declaration
           (maude-opening)
           (add-maude-output (string-append "eq C = " (compile-maude-contract (sum (contract params ...) ...)) " . \n"))
           (compile-maude-query maude-query)...
           
           (show-compiled)))]
    
    [(_ (guards guard ...) (contract params ...) maude-query ...)     
     #`(compile (guards guard ...) (sum (contract params ...)) maude-query ...)]))