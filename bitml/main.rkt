#lang racket/base

(require (for-syntax racket/base syntax/parse)
         "bitml.rkt" "model-checker.rkt" "string-helpers.rkt" "env.rkt" "terminals.rkt")

;provides the default reader for an s-exp lang
(module reader syntax/module-reader
  bitml)

(provide  participant contract withdraw deposit guards
          after auth key secret vol-deposit putrevealif
          put reveal revealif ->
          pred sum split generate-keys between
          (rename-out [btrue true] [band and] [bor or] [bnot not]
                      [b= =] [b!= !=] [b< <] [b+ +] [b- -] [b<= <=] [bsize size])
          strategy b-if do-reveal do-auth not-destory do-destory
          state check-liquid check has-more-than 
          #%module-begin #%datum #%top-interaction)
   
;compilation command
(define-syntax (contract stx)
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
           (contract params ... '(sum (contract params ...)...) "Tinit" 0 tx-v (get-participants) 0
                     (get-script-params (contract params ...)) script-params)...         
           
           ;start the maude code declaration
           (model-check (sum (contract params ...)...) (guard ...) maude-query ...)
           
           (show-compiled)))]
    
    [(_ (guards guard ...) (contract params ...) maude-query ...)     
     #`(compile (guards guard ...) (sum (contract params ...)) maude-query ...)]))