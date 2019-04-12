#lang racket/base

(require (for-syntax racket/base syntax/parse syntax/parse/define)
         "bitml.rkt" "model-checker.rkt" "string-helpers.rkt"
         "env.rkt" "terminals.rkt" "expand-inside.rkt")

;provides the default reader for an s-exp lang
(module reader syntax/module-reader
  bitml)

(provide  participant contract withdraw deposit
          after auth key secret vol-deposit putrevealif
          put reveal revealif -> tau pre
          pred sum split generate-keys between 
          (rename-out [btrue true] [band and] [bor or] [bnot not] [bdefine define]
                      [b= =] [b!= !=] [b< <] [b+ +] [b- -] [b<= <=] [bsize size]
                      [$expand ref])
          strategy b-if do-reveal do-auth not-destroy do-destroy
          state check-liquid check has-more-than check-query
          #%module-begin #%datum #%top-interaction)

;expands the constants
(define-syntax (contract stx)
  (syntax-parse stx
    #:literals (pre)
    [(_ (pre guard ...)
        (contr params ...)
        maude-query ...)
     #'(expand-inside (contract-init (pre guard ...) (contr params ...) maude-query ...))]))
   
;initializes the compilatotion
(define-syntax (contract-init stx)
  (syntax-parse stx
    #:literals (pre sum)
    [(_ (pre guard ...)
        (sum (contr params ...) ...)
        maude-query ...)

     
     #'(begin
         (reset-state)
         guard ...

         (let* ([scripts-list (list (get-script (contr params ...)) ...)]
                [script (list+sep->string scripts-list " || ")]
                [script-params (get-script-params (sum (contr params ...) ...))]
                [parent '(sum (contr params ...)...)])

           (compile-init parts deposit-txout tx-v script script-params)

           ;start the compilation of the continuation contracts
           (compile (contr params ...) parent "Tinit" 0 tx-v (get-participants) 0
                    (get-script-params (contr params ...)) script-params)...     
           
           ;start the maude code declaration
           (model-check (sum (contr params ...)...) (guard ...) maude-query ...)
           
           (show-compiled)))]
    
    [(_ (pre guard ...) (contr params ...) maude-query ...)     
     #'(contract (pre guard ...) (sum (contr params ...)) maude-query ...)]))

(define-syntax (bdefine stx)
  (syntax-parse stx
    [(_ name def)
     #'(define-syntax (name stx)
         #'def
         )]))