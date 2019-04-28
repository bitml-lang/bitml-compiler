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
          pred choice split debug-mode between 
          (rename-out [btrue true] [band and] [bor or] [bnot not] [bdefine define]
                      [b= =] [b!= !=] [b< <] [b+ +] [b- -] [b<= <=] [bsize size]
                      [b-if if] [$expand ref])
          strategy do-reveal do-auth not-destroy do-destroy not-reveal
          state check-liquid check has-more-than check-query
          #%module-begin #%datum #%top-interaction dw)

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
    #:literals (pre choice)
    [(_ (pre guard ...)
        (choice (contr params ...) ...)
        maude-query ...)

     
     #'(begin
         (reset-state)
         guard ...

         (let* ([scripts-list (list (get-script (contr params ...)) ...)]
                [script (string-append "( "(list+sep->string scripts-list " ||\n ") " )")]
                [script-params (get-script-params (choice (contr params ...) ...))]
                [parent '(choice (contr params ...)...)]
                [script-secrets (get-script-params-sym (choice (contr params ...) ...))])

           (compile-init parts deposit-txout tx-v script script-params script-secrets)

           ;start the compilation of the continuation contracts
           (compile (contr params ...) parent "Tinit" 0 tx-v (get-participants) 0
                    (get-script-params (contr params ...)) script-params)...     
           
           ;start the maude code declaration
           (model-check (choice (contr params ...)...) (guard ...) maude-query ...)
           
           (show-compiled)))]
    
    [(_ (pre guard ...) (contr params ...) maude-query ...)     
     #'(contract (pre guard ...) (choice (contr params ...)) maude-query ...)]))

(define-syntax (bdefine stx)
  (syntax-parse stx
    [(_ name body)
     #'(define-syntax (name stx)
         #'body)]

    ;https://www.greghendershott.com/fear-of-macros/Syntax_parameters.html
    [(_ name (form-params ...) body)     
     #'(begin
         (define-syntax-parameter form-params #f)...
         (define-syntax (name stx)
           (syntax-parse stx
             [(_ act-params ......)
              (syntax-parametrize ([form-params #'act-params] ...)
                                  #'body)
              ])))]))


(define-syntax (dw stx)
  (syntax-parse stx
    [(_ part)
     #'(withdraw part)]))
