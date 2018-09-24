#lang racket/base

(require (for-syntax racket/base syntax/parse syntax/to-string)
         racket/list racket/bool racket/stream)

;provides the default reader for an s-exp lang
(module reader syntax/module-reader
  bitml)

(provide  participant compile withdraw deposit guards
          after auth key secret vol-deposit putrevealif
          pred sum
          (rename-out [btrue true] [band and] [bnot not] [b= =] [b< <] [b+ +] [b- -] [bsize size])
          #%module-begin #%datum)

;--------------------------------------------------------------------------------------
;ENVIRONMENT

;security parameter (minimun secret length)
(define sec-param 128)

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
  (let ([name (format "pubkey~a~a" id (new-key-index))])
    (hash-set! pk-terms-table (cons id term) (list pk name))))

(define (pk-for-term id term)
  (hash-ref pk-terms-table (cons id term)))

(define key-index 0)

(define (new-key-index)
  (set! key-index (add1 key-index))
  key-index)

;helpers to store permanent deposits
(define parts empty)
(define (add-part id)
  (set! parts (cons id parts)))

(define deposit-txout empty)
(define (add-deposit txout)
  (set! deposit-txout (cons txout deposit-txout)))

(define tx-v 0)
(define (add-tx-v v)
  (set! tx-v (+ v tx-v)))

;helpers to store volatile deposits
(define volatile-deps-table
  (make-hash))

(define (add-volatile-dep part id val tx)
  (hash-set! volatile-deps-table id (list part val tx)))

(define (get-volatile-dep id)
  (hash-ref volatile-deps-table id))

;helpers to store the secrets
(define secrets-table
  (make-hash))

(define (add-secret id hash)
  (hash-set! secrets-table id hash))

(define (get-secret-hash id)
  (hash-ref secrets-table id))

;clear the state
(define (reset-state)
  (set! tx-v 0)
  (set! secrets-table (make-hash))
  (set! volatile-deps-table (make-hash))
  (set! deposit-txout empty)
  (set! parts empty)
  (set! tx-index 0))

;--------------------------------------------------------------------------------------
;STRING HELPERS

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
                                     (string-append "//signature with private key corresponding to " (first (pk-for-term p contract))))
                                 acc))
         "" participants))

(define (param-list->string l [sep ","])
  (let* ([s (foldr (lambda (s r) (string-append s sep r)) "" l)]
         [length (string-length s)])
    (if (> length 0)
        (substring s 0 (sub1 length))
        s)))

(define (parts->sigs-params)
  (param-list->string (map (lambda (s) (string-append "s" s)) (get-participants))))

(define (parts->sigs-param-list)
  (map (lambda (s) (string-append "s" s)) (get-participants)))

;--------------------------------------------------------------------------------------
;SYNTAX DEFINITIONS

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
                     (format "transaction ~a { \n input = ~a@~a:~a \n output = ~a BTC : fun(x) . versig(pubkey~a; x) \n "
                             tx-name parent-tx input-idx tx-sigs value part)
                     (if (> timelock 0)
                         (format "absLock = block ~a \n}\n" timelock)
                         "\n}\n"))))]
    [(_)
     (raise-syntax-error 'withdraw "wrong usage of withdraw" stx)]))

;handles after
(define-syntax (after stx)
  (syntax-parse stx   
    [(_ t (contract params ...) parent-contract parent-tx input-idx value parts timelock)
     #'(contract params ... parent-contract parent-tx input-idx value parts (max t timelock))]
    
    [(_)
     (raise-syntax-error 'bitml "wrong usage of after" stx)]))

;handles auth
(define-syntax (auth stx)
  (syntax-parse stx   
    [(_ part:string ... (contract params ...) orig-contract parent-tx input-idx value parts timelock)
     ;#'(contract params ... parent-tx input-idx value (remove part parts) timelock)]
     #'(contract params ... orig-contract parent-tx input-idx value parts timelock)] 

    [(_)
     (raise-syntax-error 'bitml "wrong usage of auth" stx)]))

  
(define-syntax (guards stx) (raise-syntax-error 'guards "wrong usage of guards" stx))

(define-syntax (deposit stx)
  (syntax-parse stx
    [(_ part:string v:number txout)
     #'(begin
         (add-part part)
         (add-deposit txout)
         (add-tx-v v))]
    [(_)
     (raise-syntax-error 'bitml "wrong usage of deposit" stx)]))

(define-syntax (vol-deposit stx)
  (syntax-parse stx
    [(_ part:string ident:id val:number txout)
     #'(add-volatile-dep part 'ident val txout)]
    [(_)
     (raise-syntax-error 'bitml "wrong usage of deposit" stx)]))

;TODO capisci come controllare l'errore a tempo statico
(define-syntax (secret stx)
  (syntax-parse stx
    [(_ ident:id hash:string)     
     #'(add-secret 'ident hash)]
    [(_)
     (raise-syntax-error 'deposit "wrong usage of secret" stx)]))


(define-syntax (sum stx) (raise-syntax-error 'bitml "wrong usage of sum" stx))

;compilation command
;todo: output script
(define-syntax (compile stx)
  (syntax-parse stx
    #:literals (guards sum)
    [(_ (guards guard ...)
        (sum (contract params ...)))
     
     #`(begin
         (reset-state)
         guard ...
         (compile-init parts deposit-txout tx-v (get-script (contract params ...)))

         ;start the compilation of the contract
         (contract params ... '(contract params ...) "Tinit" 0 tx-v (get-participants) 0))]
    [(_ (guards guard ...)
        (contract params ...))
     
     #`(begin
         (reset-state)
         guard ...
         (compile-init parts deposit-txout tx-v (get-script (contract params ...)) (get-script-params (contract params ...)))

         ;start the compilation of the contract
         (contract params ... '(contract params ...) "Tinit" 0 tx-v (get-participants) 0))]
    ))

;compiles the output-script for a Di branch. Corresponds to Bout(D) in formal def
(define-syntax (get-script stx)
  (syntax-parse stx
    #:literals (putrevealif auth after pred)
    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (~optional (contract params ...))))

     #'(get-script* '(putrevealif (tx-id ...) (sec ...) (~? (pred p) ()) (~? (contract params ...) ()))
                    '(putrevealif (tx-id ...) (sec ...) (~? (pred p) ()) (~? (contract params ...) ())))]
    [(_ (auth part ... cont)) #'(get-script* '(auth part ... cont) 'cont)]
    [(_ (after t cont)) #'(get-script* '(after t cont) 'cont)]
    [(_ x) #'(get-script* 'x 'x)]))

;auxiliar function that maintains the contract passed in the first call
(define-syntax (get-script* stx)
  (syntax-parse stx
    #:literals (putrevealif auth after pred)
    [(_ parent '(putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (~optional (contract params ...))))

     #'(let ([pred-comp (~? (string-append (compile-pred p) " && ") "")]
             [secrets (list 'sec ...)]
             [compiled-continuation (~? (get-script* parent p) (get-script* parent ()))])
         (string-append
          (foldr (lambda (x res)
                   (string-append pred-comp "sha256(" (symbol->string x) ") == hash:" (get-secret-hash x)
                                  " && size(" (symbol->string x) ") >= " (number->string sec-param) res " && "))
                 "" secrets)
          compiled-continuation))]
    [(_ parent '(auth part ... cont)) #'(get-script* parent cont)]
    [(_ parent '(after t cont)) #'(get-script* parent cont)]
    [(_ parent x)
     #'(let* ([keys (for/list([part (get-participants)])
                      (second (pk-for-term part parent)))]
              [keys-string (param-list->string keys)])
         (string-append "versig(" keys-string "; " (parts->sigs-params)  ")"))]))


;auxiliar function that maintains the contract passed in the first call
(define-syntax (get-script-params stx)
  (syntax-parse stx
    #:literals (putrevealif auth after pred)
    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (~optional (contract params ...))))

     #'(let ([cont-params (~? (get-script-params p) '())])
         (append (list (string-append (symbol->string 'sec) ":string") ...) cont-params))]
    [(_ (auth part ... cont)) #'(get-script-params cont)]
    [(_ (after t cont)) #'(get-script-params cont)]
    [(_ x) #''()]))
         

;compiles the Tinit transaction
(define (compile-init parts deposit-txout tx-v script script-params-list)
  (let* ([tx-sigs-list (for/list ([p parts]
                                  [i (in-naturals)])
                         (format "sig~a~a" p i))]
                  
         [script-params (param-list->string (append script-params-list (parts->sigs-param-list)))]


    
         [inputs (string-append "input = [ "
                                (format "~a:~a" (first deposit-txout) (first tx-sigs-list))
                                (slist->string (for/list ([p (rest tx-sigs-list)] [out (rest deposit-txout)])
                                                 (format "; ~a:~a" out p))) " ]")])


    ;compile public keys
    (for-each (lambda (s) (displayln (format "const pubkey~a = pubkey:~a" s (participant-pk s)))) (get-participants))
    (displayln "")

    ;compile pubkeys for terms
    (for-each
     (lambda (s)
       (let ([key-name (pk-for-term (first s) (rest s))])
         (displayln (format "const ~a = pubkey:~a" (second key-name) (first key-name)))))
     (hash-keys pk-terms-table))
    (displayln "")

    ;compile signatures constants for Tinit
    (for-each (lambda (e t) (displayln (string-append "const " e " : signature = _ //add signature for output " t))) tx-sigs-list deposit-txout)
  
    (displayln (format "\ntransaction Tinit { \n ~a \n output = ~a BTC : fun(~a) . ~a \n}\n" inputs tx-v script-params script))))


(define-syntax (putrevealif stx)
  (syntax-parse stx
    #:literals(pred)
    [(_ (tx-id:id ...) (sec:id ...) (~optional (pred p)) (~optional (contract params ...)) parent-contract parent-tx input-idx value parts timelock )
     
     #'(begin
         (let* ([tx-name (format "T~a" (new-tx-index))]
                [vol-dep-list (map (lambda (x) (get-volatile-dep x)) (list 'tx-id ...))] 
                [new-value (foldl (lambda (x acc) (+ (second x) acc)) value vol-dep-list)]

                [format-input (lambda (x sep acc) (format "~a:sig~a~a ~a" (third (get-volatile-dep x)) (symbol->string x) sep acc))]
              
                [vol-inputs (foldl (lambda (x acc) (format-input x ";" acc))

                                   (format-input (first (list 'tx-id ...)) "" "")
                                   (rest (list 'tx-id ...)))]

              
                [script (~? (get-script (contract params ...)) "")]
                [script-params (param-list->string (append
                                                    (~? (get-script-params (contract params ...)) '())
                                                    (parts->sigs-param-list)))]
                [script-params (parts->sigs-params)]
                [tx-sigs (participants->tx-sigs parts tx-name)]
                [inputs (string-append "input = [ " parent-tx "@" (number->string input-idx) ":" tx-sigs "; " vol-inputs " ]")])

           ;compile signatures constants for the volatile deposits
           (for-each
            (lambda (x) (displayln (string-append "const sig" (symbol->string x) " : signature = _ //add signature for output " (third (get-volatile-dep x)))))
            (list 'tx-id ...))

           (displayln (participants->sigs-declar parts tx-name parent-contract))

         
           (displayln (format "\ntransaction ~a { \n ~a \n output = ~a BTC : fun(~a) . ~a \n}\n" tx-name inputs new-value script-params script))
         
           (~? (contract params ... '(contract params ...) tx-name input-idx new-value parts timelock))))]))


;operators for predicate in putrevealif
(define-syntax (btrue stx) (raise-syntax-error 'true "wrong usage of true" stx))
(define-syntax (band stx) (raise-syntax-error 'and "wrong usage of and" stx))
(define-syntax (bnot stx) (raise-syntax-error 'not "wrong usage of not" stx))
(define-syntax (b= stx) (raise-syntax-error '= "wrong usage of =" stx))
(define-syntax (b< stx) (raise-syntax-error '< "wrong usage of <" stx))
(define-syntax (b+ stx) (raise-syntax-error '+ "wrong usage of +" stx))
(define-syntax (b- stx) (raise-syntax-error '- "wrong usage of -" stx))
(define-syntax (bsize stx) (raise-syntax-error 'size "wrong usage of size" stx))
(define-syntax (pred stx) (raise-syntax-error 'pred "wrong usage of pred" stx))

(define-syntax (compile-pred stx)
  (syntax-parse stx
    #:literals(btrue band bnot)
    [(_ btrue) #'"true"]
    [(_ (band a b)) #'(string-append (compile-pred a) " && " (compile-pred b))]
    [(_ (bnot a)) #'(string-append "!(" (compile-pred a) ")")]
    [(_ p) #'(compile-pred-exp p)]))


(define-syntax (compile-pred-exp stx)
  (syntax-parse stx
    #:literals(b= b< b+ b- bsize)
    [(_ (b= a b)) #'(string-append (compile-pred-exp a) "==" (compile-pred-exp b))]
    [(_ (b< a b)) #'(string-append (compile-pred-exp a) "<" (compile-pred-exp b))]
    [(_ (b+ a b)) #'(string-append "(" (compile-pred-exp a) "+" (compile-pred-exp b) ")")]
    [(_ (b- a b)) #'(string-append "(" (compile-pred-exp a) "-" (compile-pred-exp b) ")")]
    [(_ (bsize a)) #'(string-append "(size(" (compile-pred-exp a) ") - " (number->string sec-param) ")")]
    [(_ a:number) #'(number->string a)]
    [(_ a:string) #'a]
    [(_ a:id) #'(symbol->string 'a)]
    [(_) (raise-syntax-error 'put-if "wrong if predicate" stx)]))