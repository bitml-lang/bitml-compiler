#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/list racket/string
         "helpers.rkt" "env.rkt" "exp.rkt" "terminals.rkt")

(provide (all-defined-out))

;SYNTAX DEFINITIONS

;turns on the generation of the keys
(define-syntax (debug-mode stx)
  #'(set-gen-keys!))

;turns on the constraint solving
(define-syntax (auto-generate-secrets stx)
  #'(set-gen-secs!))

;turns on the constraint solving
(define-syntax (verification-only stx)
  #'(set-hide-tx!))

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

(define-syntax (deposit stx)
  (syntax-parse stx
    [(_ part:string v:number txout)
     #'(begin
         (add-part part)
         (add-deposit txout)
         (add-tx-v v))]
    [(_)
     (raise-syntax-error #f "wrong usage of deposit" stx)]))

(define-syntax (fee stx)
  (syntax-parse stx
    [(_ part:string v:number txout)
     #'(add-fee-dep part v txout)]
    [(_)
     (raise-syntax-error #f "wrong usage of fee deposit" stx)]))

(define-syntax (vol-deposit stx)
  (syntax-parse stx
    [(_ part:string ident:id val:number txout)
     #'(add-volatile-dep part 'ident val txout)]
    [(_)
     (raise-syntax-error #f "wrong usage of deposit" stx)]))

;TODO capisci come controllare l'errore a tempo statico
(define-syntax (secret stx)
  (syntax-parse stx
    [(_ part:string ident:id hash:string)     
     #'(add-secret part 'ident hash)]
    [(_)
     (raise-syntax-error 'deposit "wrong usage of secret" stx)]))


;prepares and displays the output of the compilation
(define (show-compiled)

  ;if the keys where auto-generated, add them to the output
  (when gen-keys
    ;compile pubkeys for terms
    (for-each
     (lambda (s)
       (let ([key-name (pk-for-term (first s) (rest s))])
         (add-output (format "const ~a = pubkey:~a" (second key-name) (first key-name)) #t)))
     (hash-keys pk-terms-table))
    (add-output "" #t))

  (unless (hide-tx?)
    (displayln output)))

;compiles the output-script for a Di branch. Corresponds to Bout(D) in formal def
(define-syntax (get-script stx)
  (syntax-parse stx
    #:literals (putrevealif auth after pred revealif put reveal)
    [(_ (reveal (sec:id ...) (contract params ...)))
     #'(get-script (putrevealif () (sec ...) (contract params ...)))]
    [(_ (revealif (sec:id ...) (pred p) (contract params ...)))
     #'(get-script (putrevealif () (sec ...) (pred p) (contract params ...)))]
    [(_ (put (tx:id ...) (contract params ...)))
     #'(get-script (putrevealif (tx ...) () (contract params ...)))]
    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...)))
     (let [(contract #''(putrevealif (tx-id ...) (sec ...) (~? (pred p)) (contract params ...)) )]
       #`(get-script* #,contract #,contract))]

    [(_ (auth part ... cont)) #'(get-script* '(auth part ... cont) 'cont)]
    [(_ (after t cont)) #'(get-script* '(after t cont) 'cont)]
    [(_ x) #'(get-script* 'x 'x)]))

;auxiliar function that maintains the contract passed in the first call
(define-syntax (get-script* stx)
  (syntax-parse stx
    #:literals (putrevealif auth after pred)
    [(_ parent '(putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...)))

     #'(let ([pred-comp (~? (string-append (compile-pred p) " && ") "")]
             [secrets (list 'sec ...)]
             [compiled-continuation (~? (get-script* parent p) (get-script* parent ()))])
         (string-append pred-comp compiled-continuation))]
    [(_ parent '(auth part ... cont)) #'(get-script* parent cont)]
    [(_ parent '(after t cont)) #'(get-script* parent cont)]
    [(_ parent x)
     #'(let* ([keys (for/list([part (get-participants)])
                      (second (pk-for-term part parent)))]
              [keys-string (list+sep->string keys)])
         (string-append "versig(" keys-string "; " (parts->sigs-params (get-participants))  ")"))]))

(define (get-secrets-check-script secrets)
  (foldr (lambda (x res)
           (string-append "sha256(" (symbol->string x) ") == hash:" (get-secret-hash x)
                          " && size(" (symbol->string x) ") >= " (number->string sec-param) " && " res))
         "" secrets))

;return the parameters for the script obtained by get-script
(define-syntax (get-script-params stx)
  (syntax-parse stx
    #:literals (putrevealif auth after pred choice split reveal revealif put)
    [(_ (reveal (sec:id ...) (contract params ...)))
     #'(get-script-params (putrevealif () (sec ...) (contract params ...)))]
    [(_ (revealif (sec:id ...) (pred p) (contract params ...)))
     #'(get-script-params (putrevealif () (sec ...) (pred p) (contract params ...)))]
    [(_ (put (tx:id ...) (contract params ...)))
     #'(get-script-params (putrevealif (tx ...) () (contract params ...)))]
    
    [(_ (choice (contract params ...)...))
     #'(remove-duplicates (append (get-script-params (contract params ...)) ...))]
    
    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (~optional (contract params ...))))
     #'(list (string-append (symbol->string 'sec) ":string") ...)]
    [(_ (auth part ... cont)) #'(get-script-params cont)]
    [(_ (after t cont)) #'(get-script-params cont)]
    [(_ x) #''()]))

(define-syntax (get-script-params-sym stx)
  (syntax-parse stx
    #:literals (putrevealif auth after pred choice split reveal revealif put)
    [(_ (reveal (sec:id ...) (contract params ...)))
     #'(get-script-params-sym (putrevealif () (sec ...) (contract params ...)))]
    [(_ (revealif (sec:id ...) (pred p) (contract params ...)))
     #'(get-script-params-sym (putrevealif () (sec ...) (pred p) (contract params ...)))]
    [(_ (put (tx:id ...) (contract params ...)))
     #'(get-script-params-sym (putrevealif (tx ...) () (contract params ...)))]
    
    [(_ (choice (contract params ...)...))
     #'(remove-duplicates (append (get-script-params-sym (contract params ...)) ...))]
    
    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (~optional (contract params ...))))
     #'(list 'sec ...)]
    [(_ (auth part ... cont)) #'(get-script-params-sym cont)]
    [(_ (after t cont)) #'(get-script-params-sym cont)]
    [(_ x) #''()]))
         

;compiles the Tinit transaction
(define (compile-init parts deposit-txout tx-v fee-v script script-params-list script-secrets)
  (let* ([tx-sigs-list (for/list ([p parts]
                                  [i (in-naturals)])
                         (format "sig~a~a" p i))]                  
         [script-params (list+sep->string (append script-params-list (parts->sigs-param-list (get-participants))))]
         [deposits-string (list+sep->string (for/list ([p tx-sigs-list]
                                                       [out deposit-txout])
                                              (format "~a:~a" out p))
                                            "; ")]
         [fee-deposits-string (list+sep->string (for/list ([pair (get-fee-dep-pairs)])
                                                  (format "~a:sig~aFee" (second pair) (first pair)))
                                                "; ")]
         [inputs (string-append "input = [ " deposits-string "; " fee-deposits-string " ]")])
    ;compile public keys    
    (for-each (lambda (s) (add-output (format "const pubkey~a = pubkey:~a" s (participant-pk s)))) (get-participants))
    (add-output "")

    (unless gen-keys
      ;compile pubkeys for terms
      (for-each
       (lambda (s)
         (let ([key-name (pk-for-term (first s) (rest s))])
           (add-output (format "const ~a = pubkey:~a" (second key-name) (first key-name)))))
       (hash-keys pk-terms-table))
      (add-output ""))

    ;compile signatures constants for Tinit
    (for-each (lambda (e t) (add-output (string-append "const " e " : signature = _ //add signature for output " t))) tx-sigs-list deposit-txout)

    ;compile fee signatures constants for Tinit
    (for-each (lambda (x) (add-output (format "const sig~aFee : signature = _ //add signature for output ~a"
                                              (first x) (second x)))) (get-fee-dep-pairs))
  
    (add-output (format "\ntransaction Tinit { \n ~a \n output = ~a BTC : fun(~a) . ~a\n (~a) \n}\n"
                        inputs (btc+ (get-remaining-fee fee-v) tx-v) script-params
                        (get-secrets-check-script script-secrets) script))))


(define-syntax (compile stx)
  (syntax-parse stx
    #:literals(pred choice -> putrevealif split withdraw after auth reveal revealif put tau)
    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (choice (contract params ...)...))
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(begin
         (let* ([tx-name (format "T~a" (new-tx-index))]
                [vol-dep-list (map (lambda (x) (get-volatile-dep x)) (list 'tx-id ...))] 
                [new-value (foldl (lambda (x acc) (+ (second x) acc)) value vol-dep-list)]

                [format-input (lambda (x sep acc) (format "~a:sig~a" (third (get-volatile-dep x)) (symbol->string x)))]

                [vol-inputs (list 'tx-id ...)]
              
                [vol-inputs-str (if (> 0 (length vol-inputs))
                                    (string-append "; " (list+sep->string (map (lambda (x) (format-input x)) vol-inputs)))
                                    "")]
                [scripts-list (list (get-script (contract params ...)) ...)]
                [script-secrets (remove-duplicates (append (get-script-params-sym (contract params ...)) ...))]
                [script (string-append (get-secrets-check-script script-secrets)
                                       "\n(" (list+sep->string scripts-list " ||\n ") ")")]

                [script-params (list+sep->string (append
                                                  (remove-duplicates (append (get-script-params (contract params ...)) ...))
                                                  (parts->sigs-param-list (get-participants))))]
                [sec-wit (list+sep->string (map (lambda (x) (if (member x sec-to-reveal) (format-secret x) "0")) all-secrets) " ")]
                [tx-sigs (participants->tx-sigs parts tx-name)]
                [inputs (string-append "input = [ " parent-tx "@" (number->string input-idx) ":" sec-wit " " tx-sigs vol-inputs-str "]")])

           ;compile signatures constants for the volatile deposits
           (for-each
            (lambda (x) (add-output (string-append "const sig" (symbol->string x) " : signature = _ //add signature for output " (third (get-volatile-dep x)))))
            (list 'tx-id ...))

           (add-output (participants->sigs-declar parts tx-name parent-contract))

           ;compile the secrets declarations
           (for-each
            (lambda (x) (add-output (string-append "const sec_" x " = _ //add value of secret " (string-replace x ":string" ""))))
            sec-to-reveal)

         
           (add-output (format "\ntransaction ~a { \n ~a \n output = ~a BTC : fun(~a) . ~a \n}\n"
                               tx-name inputs (btc+ (get-remaining-fee fee-v) new-value) script-params script))

           
           (compile (contract params ...) '(choice (contract params ...)...)
                    tx-name 0 new-value (get-remaining-fee fee-v)
                    parts 0 (get-script-params (contract params ...)) (get-script-params parent-contract))...))]

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...))
        parent-contract parent-tx input-idx value fee-v parts timelock  sec-to-reveal all-secrets)
     #'(compile (putrevealif (tx-id ...) (sec ...) (~? (pred p)) (choice (contract params ...)))
                parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]
    
    
    [(_ (split (val:number -> (choice (contract params ...)...))...)
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #:with splits-count #'(length (list val ...))
     #'(begin    
         (let* ([tx-name (format "T~a" (new-tx-index))]
                [values-list (list val ...)]
                [script-secrets-list (list (remove-duplicates (append (get-script-params-sym (contract params ...)) ...))...)]
                [subscripts-list (list (list (get-script (contract params ...)) ...)...)]
                [script-list (for/list([subscripts subscripts-list])
                               (string-append "("(list+sep->string subscripts " ||\n ") ")"))]
                [script-params-list (list (list+sep->string (append
                                                             (remove-duplicates (append (get-script-params (contract params ...)) ...))
                                                             (parts->sigs-param-list (get-participants))))...)]  
                [sec-wit (list+sep->string (map (lambda (x) (if (member x sec-to-reveal) (format-secret x) "\"\"")) all-secrets) " ")]
                [tx-sigs (participants->tx-sigs parts tx-name)]
                [inputs (string-append "input = [ " parent-tx "@" (number->string input-idx) ":" sec-wit " " tx-sigs "]")]
                [outputs (for/list([v values-list]
                                   [script script-list]
                                   [script-params script-params-list]
                                   [secrets script-secrets-list])
                           (format "~a BTC : fun(~a) . ~a (~a)" (btc+ v (get-remaining-fee-split fee-v splits-count))
                                   script-params (get-secrets-check-script secrets) script))]
                [output (string-append "output = [ " (list+sep->string outputs ";\n\t") " ]")]
                [count 0])                

           (add-output (participants->sigs-declar parts tx-name parent-contract))
           
           (if (not (bitcoin-equal (apply + values-list) value)) 
               (raise-syntax-error 'bitml
                                   (format "split spends ~a BTC but it receives ~a BTC" (+ val ...) value)
                                   '(split (val (choice (contract params ...)...))...))

               (begin
                 ;compile the secrets declarations
                 (for-each
                  (lambda (x) (add-output (string-append "const sec_" x " : string = _ //add value of secret " (string-replace x ":string" ""))))
                  sec-to-reveal)

                 (add-output (format "\ntransaction ~a { \n ~a \n ~a \n~a}\n" tx-name inputs output (format-timelock timelock)))
           
                 ;compile the continuations
                
                 (begin
                   (execute-split '(contract params ...)...
                                  tx-name count val
                                  (get-remaining-fee-split fee-v splits-count) parts)
                   (set! count (add1 count)))...))))]

    ;allow for split branches with unary choices
    [(_ (split (val:number -> (~or (choice (contract params ...)...) (scontract sparams ...)))...)
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(compile (split (val -> (~? (choice (scontract sparams ...))) (~? (choice (contract params ...)...)) )...)
                parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]

    ;syntax sugar for putrevealif
    [(_ (put (tx-id:id ...) (choice (contract params ...)...))
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(compile (putrevealif (tx-id ...) () (choice (contract params ...)...))
                parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]
    [(_ (put (tx-id:id ...) (contract params ...))
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(compile (putrevealif (tx-id ...) () (contract params ...))
                parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]

    [(_ (reveal (sec:id ...) (choice (contract params ...)...))
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(compile (putrevealif () (sec ...) (choice (contract params ...)...))
                parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]
    [(_ (reveal (sec:id ...) (contract params ...))
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(compile (putrevealif () (sec ...) (contract params ...))
                parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]

    [(_ (revealif (sec:id ...) (pred p) (choice (contract params ...)...))
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(compile (putrevealif () (sec ...) (pred p) (choice (contract params ...)...))
                parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]
    [(_ (revealif (sec:id ...) (pred p) (contract params ...))
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(compile (putrevealif () (sec ...) (pred p) (contract params ...))
                parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]

    [(_ (tau (contract params ...))
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(compile (putrevealif () () (contract params ...))
                parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]


    ;compiles withdraw to transaction  
    [(_ (withdraw part)
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)     
     #'(begin
         (let* ([tx-name (new-tx-name)]
                [tx-sigs (participants->tx-sigs parts tx-name)]
                [sec-wit (list+sep->string (map (lambda (x) (if (member x sec-to-reveal) (format-secret x) "0")) all-secrets) " ")]
                [inputs (string-append "input = [ " parent-tx "@" (number->string input-idx) ": " sec-wit " " tx-sigs "]")])


           (add-output (participants->sigs-declar parts tx-name parent-contract))
         
           (add-output (string-append
                        (format "transaction ~a { \n ~a \n output = ~a BTC : fun(x) . versig(pubkey~a; x) \n "
                                tx-name inputs (btc+ (get-remaining-fee fee-v) value) part)
                        (if (> timelock 0)
                            (format "absLock = block ~a \n}\n" timelock)
                            "\n}\n")))))]
  
    [(_ (after t (contract params ...))
        parent-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     #'(compile (contract params ...)
                parent-contract parent-tx input-idx value fee-v parts (max t timelock) sec-to-reveal all-secrets)]

    [(_ (auth part:string ... (contract params ...))
        orig-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)
     ;#'(contract params ... parent-tx input-idx value (remove part parts) timelock)]
     #'(compile (contract params ...)
                orig-contract parent-tx input-idx value fee-v parts timelock sec-to-reveal all-secrets)]
    
    [(_ contract rest ...) (raise-syntax-error 'bitml "Invalid syntax" #f)]))


(define-syntax (execute-split stx)
  (syntax-parse stx
    [(_ '(contract params ...) ... parent-tx input-idx value fee-v parts)     
     #'(let ([choice-secrets (get-script-params (choice (contract params ...)...))])
         ;(begin
         ;(displayln '(contract params ...))
         ;(displayln (format "parametri ~a ~a ~a ~a ~a" parent-tx input-idx value parts choice-secrets))
         ;(displayln (get-script-params (contract params ...)))
         ;(displayln ""))...
         
         (compile (contract params ...) '(contract params ...)
                  parent-tx input-idx value fee-v parts 0
                  choice-secrets (get-script-params (contract params ...)))...)]))
