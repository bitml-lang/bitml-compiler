#lang racket

(require syntax/parse/define syntax/id-table racket/stxparam
         (for-syntax racket/list racket/format))

;provides the default reader for an s-exp lang
(module reader syntax/module-reader
  bitml)

(provide (all-from-out racket)
         participant advertise withdraw deposit guards after)

;function to enumerate tx indexes
(define tx-index 0)

(define (new-tx-index)
  (set! tx-index (add1 tx-index))
  tx-index)

;helpers to store and retrieve participants info
(define participants-table
  (make-hash))

(define (add-participant id pk)
  (hash-set! participants-table id pk))

(define (participant-pk id)
  (hash-ref participants-table id))

(define (get-participants)
  (hash-keys participants-table))

;helpers to generate string transactions
(define (slist->string l)
  (foldr (lambda (s r) (string-append s r)) "" l))

(define (participants->tx-params participants)
  (define s
    (foldl (lambda (p acc) (string-append  "s" (format "~a" p) ":signature," acc))  "" participants))
  (substring s 0 (sub1 (string-length s))))

(define (participants->tx-params-list participants)
  (for/list([p participants])
    (string-append  "s" (format "~a" p))))

(define (participants->tx-sigs participants)
  (foldl (lambda (p acc) (string-append  "s" (format "~a" p) " " acc))  "" participants))

;declaration of a participant
;associates a name to a public key
(define-simple-macro (participant ident:string pubkey:string)
  (add-participant 'ident pubkey))

;compiles withdraw to transaction
(define-syntax (withdraw stx)
  (syntax-parse stx    
    [(_ part parent-tx input-idx value parts timelock)
     #'(begin
         (define tx-params (participants->tx-params (get-participants)))
         (define tx-sigs (participants->tx-sigs (get-participants)))

         (displayln (if (> timelock 0)
                        (format "transaction T~a(~a,~a) { \n input = ~a@~a:~a \n output = ~a BTC : fun(x) . versig(addr~a; x) \n absLock = block ~a \n}\n"
                                (new-tx-index) tx-params parent-tx parent-tx input-idx tx-sigs value part timelock)
                        (format "transaction T~a(~a,~a) { \n input = ~a@~a:~a \n output = ~a BTC : fun(x) . versig(addr~a; x) \n}\n"
                                (new-tx-index) tx-params parent-tx parent-tx input-idx tx-sigs value part))))]
    [(_)
     (raise-syntax-error stx '! "cannot use withdraw alone")]))

;gestisce after
(define-syntax (after stx)
  (syntax-parse stx   
    [(_ t (contract params ...) parent-tx input-idx value parts timelock)
     #'(contract params ... parent-tx input-idx value parts (max t timelock))]
    
    [(_)
     (raise-syntax-error stx '! "cannot use withdraw alone")]))
     
;keywords for the next macro
(define-syntax (guards stx) (raise-syntax-error 'guards "cannot use guards alone" stx))
(define-syntax (deposit stx) (raise-syntax-error 'deposit "cannot use deposit alone" stx))
;command compilation
(define-syntax (advertise stx)
  (syntax-parse stx
    #:literals (guards deposit)    
    [(_ (guards (deposit part:string v:number txout) ... ) (contract params ...))

     (define deposit-part (syntax->list #'(part ...)))
     
     #`(begin
         (define deposit-parts (list 'part ...))
         (define deposit-txout (list txout ...))
         (define tx-params-list (for/list ([p deposit-parts]
                                           [i (in-naturals)])
                                  (format "~a~a" p i)))     
         (define tx-params-string
           (string-append (first tx-params-list)
                          (slist->string (for/list ([p (rest tx-params-list)])                                      
                                           (format ",~a" p)))))       
         (define tx-v (+ v ...))
         
         ;dichiara le pk
         (for-each (lambda (s) (displayln (format "const pubkey~a = pubkey:~a" s (participant-pk s)))) (get-participants))         
         (define inputs (string-append "input = [ "
                                       (format "~a:~a" (first deposit-txout) (first tx-params-list))
                                       (slist->string (for/list ([p (rest tx-params-list)] [out (rest deposit-txout)])
                                                        (format "; ~a:~a" out p))) " ]"))                   
         (displayln (format "\ntransaction Tinit(~a) { \n ~a \n output = ~a BTC \n}\n" tx-params-string inputs tx-v))

         ;procedi compilando il contratto
         (contract params ... "Tinit" 0 tx-v (get-participants) 0))]))