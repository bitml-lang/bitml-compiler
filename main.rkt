#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/list racket/bool)

;provides the default reader for an s-exp lang
(module reader syntax/module-reader
  bitml)

(provide (all-from-out racket/base)
         participant advertise withdraw deposit guards after auth key)

;function to enumerate tx indexes
(define tx-index 0)

(define (new-tx-index)
  (set! tx-index (add1 tx-index))
  tx-index)

(define (new-tx-name)
  (format "T~a" (new-tx-index)))

;helpers to store and retrieve participants' public keys
(define participants-table
  (make-hash))

(define (add-participant id pk)
  (hash-set! participants-table id pk))

(define (participant-pk id)
  (hash-ref participants-table id))

(define (get-participants)
  (hash-keys participants-table))

;helpers to store and retrieve participants' public keys for terms
(define pk-terms-table
  (make-hash))

(define (add-pk-for-term id term pk)
  (hash-set! pk-terms-table (cons id term) pk))

(define (pk-for-term id term)
  (hash-ref pk-terms-table (cons id term)))

;helpers to generate string transactions
(define (slist->string l)
  (foldr (lambda (s r) (string-append s r)) "" l))

(define (participants->tx-params-list participants)
  (for/list([p participants])
    (string-append  "s" (format "~a" p))))

(define (participants->tx-sigs participants tx-name)
  (foldl (lambda (p acc) (format "sig~a~a ~a" p tx-name acc))  "" participants))

(define (participants->tx-sigsl participants tx-name)
  (map (lambda (p) (format "sig~a~a ~a" p tx-name)) participants))

(define (participants->sigs-declar participants tx-name [contract #f])
  (foldr (lambda (p acc) (format "const sig~a~a : signature = _ ~a\n~a" p tx-name
                                 (if (false? contract)
                                     ""
                                     (string-append "//signature with private key of " (pk-for-term p contract)))
                                 acc))
         "" participants))


;declaration of a participant
;associates a name to a public key
(define-syntax (participant stx)
  (syntax-parse stx
    [(_ ident:string pubkey:string)
     #'(add-participant 'ident pubkey)]))

;declaration of a participant
;associates a name and a term to a public key
(define-syntax (key stx)
  (syntax-parse stx
    [(_ ident:string term pubkey:string)
     #'(add-pk-for-term 'ident 'term pubkey)]))

;compiles withdraw to transaction
(define-syntax (withdraw stx)
  (syntax-parse stx    
    [(_ part parent-contract parent-tx input-idx value parts timelock)
     #'(begin         
         (define tx-name (new-tx-name))
         (define tx-sigs (participants->tx-sigs parts tx-name))


         (displayln (participants->sigs-declar parts tx-name parent-contract))
         
         (displayln (string-append
                     (format "transaction ~a { \n input = ~a@~a:~a \n output = ~a BTC : fun(x) . versig(addr~a; x) \n "
                             tx-name parent-tx input-idx tx-sigs value part)
                     (if (> timelock 0)
                         (format "absLock = block ~a \n}\n" timelock)
                         "\n}\n"))))]
    [(_)
     (raise-syntax-error stx '! "cannot use withdraw alone")]))

;handles after
(define-syntax (after stx)
  (syntax-parse stx   
    [(_ t (contract params ...) parent-contract parent-tx input-idx value parts timelock)
     #'(contract params ... parent-contract parent-tx input-idx value parts (max t timelock))]
    
    [(_)
     (raise-syntax-error stx '! "cannot use after alone")]))

;handles auth
(define-syntax (auth stx)
  (syntax-parse stx   
    [(_ part:string (contract params ...) orig-contract parent-tx input-idx value parts timelock)
     ;#'(contract params ... parent-tx input-idx value (remove part parts) timelock)]
     #'(contract params ... orig-contract parent-tx input-idx value parts timelock)] 

    [(_)
     (raise-syntax-error stx '! "cannot use auth alone")]))
     
;keywords for the next macro
(define-syntax (guards stx) (raise-syntax-error 'guards "cannot use guards alone" stx))
(define-syntax (deposit stx) (raise-syntax-error 'deposit "cannot use deposit alone" stx))

;compilation command
;todo: output script
(define-syntax (advertise stx)
  (syntax-parse stx
    #:literals (guards deposit)    
    [(_ (guards (deposit part:string v:number txout) ... ) (contract params ...))

     (define deposit-part (syntax->list #'(part ...)))
     
     #`(begin
         (define deposit-parts (list 'part ...))
         (define deposit-txout (list txout ...))
         (define tx-sigs-list (for/list ([p deposit-parts]
                                           [i (in-naturals)])
                                  (format "sig~a~a" p i)))     
         #;(define tx-params-string
           (string-append (first tx-params-list)
                          (slist->string (for/list ([p (rest tx-params-list)])                                      
                                           (format ",~a" p)))))       
         (define tx-v (+ v ...))
         
         ;compile public key
         (for-each (lambda (s) (displayln (format "const pubkey~a = pubkey:~a" s (participant-pk s)))) (get-participants))
         (displayln "")

         ;compile signatures constants for Tinit
         (for-each (lambda (e) (displayln (string-append "const " e " : signature = _"))) tx-sigs-list)

         
         (define inputs (string-append "input = [ "
                                       (format "~a:~a" (first deposit-txout) (first tx-sigs-list))
                                       (slist->string (for/list ([p (rest tx-sigs-list)] [out (rest deposit-txout)])
                                                        (format "; ~a:~a" out p))) " ]"))                   
         (displayln (format "\ntransaction Tinit { \n ~a \n output = ~a BTC \n}\n" inputs tx-v))

         ;start the compilation of the contract
         (contract params ... '(contract params ...) "Tinit" 0 tx-v (get-participants) 0))]))