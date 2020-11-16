#lang racket/base

(require (for-syntax racket/base syntax/parse syntax/parse/define)
         "bitml.rkt" "model-checker.rkt" "helpers.rkt"
         "env.rkt" "terminals.rkt" "expand-inside.rkt")

;provides the default reader for an s-exp lang
(module reader syntax/module-reader
  bitml)

(provide  participant contract withdraw deposit
          after auth key secret vol-deposit putrevealif
          put reveal revealif -> tau pre rngt
          pred choice split debug-mode between 
          (rename-out [btrue true] [band and] [bor or] [bnot not] [define-rewrite-rule define]
                      [b= =] [b!= !=] [b< <] [b+ +] [b- -] [b<= <=] [bsize size]
                      [b-if if] [$expand ref])
          define-syntax-rule fee verification-only define-rec
          strategy do-reveal do-auth not-destroy do-destroy not-reveal secrets
          state check-liquid check has-at-least check-query auto-generate-secrets
          #%module-begin #%datum #%top-interaction)

;expands the constants
(define-syntax (contract stx)
  (syntax-parse stx
    #:literals (pre)
    [(_ (pre guard ...)
        (contr params ...)
        maude-query ...)
     #'(expand-inside (contract-init (pre guard ...) (contr params ...) maude-query ...))]))
   
;initializes the compilation
(define-syntax (contract-init stx)
  (syntax-parse stx
    #:literals (pre choice define-rec)
    [(_ (pre guard ...)
        (choice (contr params ...) ...)
        (define-rec name:string
          (pre (deposit p v d)...)...
          contr1) ...
        maude-query ...)

     
     #'(begin
         (reset-state)
         guard ...

         (let* ([scripts-list (list (get-script (contr params ...)) ...)]
                [script (string-append "( "(list+sep->string scripts-list " ||\n ") " )")]
                [script-params (get-script-params (choice (contr params ...) ...))]
                [parent '(choice (contr params ...)...)]
                [script-secrets (get-script-params-sym (choice (contr params ...) ...))])

           (unless (hide-tx?)

             (define start-time (current-inexact-milliseconds))           

             (compile-init parts deposit-txout tx-v avail-fee script script-params)

             ;start the compilation of the continuation contracts
             (compile (contr params ...) parent "Tinit" 0 tx-v (get-remaining-fee avail-fee) (get-participants) 0
                      (get-script-params (contr params ...)) script-params)...

             ;compile the renegotiation contracts
             (begin
               (add-output (string-append "// Transactions for contract " 'name))
               (compile (tau contr1) 'cont1r "" 0 (+ tx-v v ... ...) (get-remaining-fee avail-fee) (get-participants) 0
                        (get-script-params contr1) (get-script-params contr1)))...

             (displayln (format "\\\\Compilation time: ~a ms" (round (- (current-inexact-milliseconds) start-time)))))
           
           ;compute the model-checking result for each query
           (model-check (choice (contr params ...)...) (define-rec name contr1) ... (pre guard ...) maude-query ...)
           
           (show-compiled)))]
    
    [(_ (pre guard ...) (contr params ...) maude-query ...)     
     #'(contract (pre guard ...) (choice (contr params ...)) maude-query ...)]))

(define-syntax (define-rewrite-rule stx)
  (syntax-parse stx
    [(_ (the-id:id the-exp:expr ...) body:expr)
     #'(define-syntax (the-id stx)
         (syntax-parse stx
           [(_ the-exp ...)
            #'body]))]))