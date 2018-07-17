#lang racket

(require syntax/parse/define syntax/id-table racket/stxparam
         (for-syntax racket/list racket/format))

(module reader syntax/module-reader
  bitml)

(provide (all-from-out racket)
         participant advertise withdraw deposit guards)

(define tx-index 0)

(define (new-tx-index)
  (set! tx-index (add1 tx-index))
  tx-index)

(define participants-table
  (make-hash))

(define (add-participant id pk)
  (hash-set! participants-table id pk))

(define (participant-pk id)
  (hash-ref participants-table id))

(define (get-participants)
  (hash-keys participants-table))

;dichiarazione di un partecipante
;associa il nome alla chiave pubblica
(define-simple-macro (participant ident:id (~literal @) pubkey:string)
  (add-participant 'ident pubkey))

(define-syntax (guards stx) (raise-syntax-error 'guards "cannot use guards alone" stx))
(define-syntax (deposit stx) (raise-syntax-error 'deposit "cannot use deposit alone" stx))

(define (slist->string l)
  (foldr (lambda (s r) (string-append s r)) "" l))

;compila withdraw in tx
(define-syntax (withdraw stx)
  (syntax-parse stx    
    [(_ part parent-tx input-idx value parts timelock)
     #'(displayln (if (> timelock 0)
                      (format "transaction T~a(s) { \n input = ~a@~a:s \n output = ~a BTC : fun(x) . versig(addr~a; x) \n absLock = date ~a \n}\n"
                              (new-tx-index) parent-tx input-idx value part timelock)
                      (format "transaction T~a(s) { \n input = ~a@~a:s \n output = ~a BTC : fun(x) . versig(addr~a; x) \n}\n"
                              (new-tx-index) parent-tx input-idx value part)))]
    [(_)
     (raise-syntax-error stx '! "cannot use withdraw alone")]))
     

;comando di compilazione del contratto
(define-syntax (advertise stx)
  (syntax-parse stx
    #:literals (guards deposit)
    [(_ (guards (deposit part:id v:number txout) ... ) (contract params ...))

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
         (for-each (lambda (s) (displayln (format "cost addr~a = address:~a" s (participant-pk s)))) (get-participants))         
         (define inputs (string-append "input: [ "
                                       (format "~a:~a" (first tx-params-list) (first deposit-txout))
                                       (slist->string (for/list ([p (rest tx-params-list)] [out (rest deposit-txout)])
                                                        (format "; ~a:~a" p out))) " ]"))                   
         (displayln (format "\ntransaction Tinit(~a) { \n ~a \n out: ~a \n}\n" tx-params-string inputs tx-v))

         ;procedi compilando il contratto
         (contract 'params ... "Tinit" 0 tx-v (get-participants) 0))]))