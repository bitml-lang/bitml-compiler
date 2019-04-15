#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/list racket/port racket/system racket/match racket/string racket/math
         "bitml.rkt" "string-helpers.rkt" "env.rkt" "terminals.rkt" "exp.rkt" "constraints.rkt")

(provide (all-defined-out))

(define maude-output "")

(define (reset-maude-out)
  (set! maude-output ""))

(define (add-maude-output . str-list )
  (set! maude-output (string-append maude-output (list+sep->string str-list "") "\n" )))

(define-syntax (model-check stx)
  (syntax-parse stx
    [(_ contract (guard ...) query ...)
     #'(begin
         (define start-time (current-inexact-milliseconds))           
         (define flag #f)
         (define secrets-list (get-secrets-lengths contract (guard ...)))

         ;for each query
         (begin
           (display "\n/*=============================================================================\nModel checking result for ")
           (displayln 'query)
           (displayln "")
           (set! flag #f)

           ;model check the query for each solution of the constraints
           (for ([secrets-map secrets-list])
             #:break flag        
             (reset-maude-out)
             (maude-opening)
             (add-maude-output (string-append "eq MContr = " (compile-maude-contract contract) " . \n"))
             (let ([result (execute-maude-query secrets-map query)])

               ;if the model checking returns false display the cex
               (unless (car result)
                 (displayln "Result: false")
                 (unless (hash-empty? secrets-map)
                   (secrets-pretty-print secrets-map))
                 (displayln (cdr result))
                 (set! flag #t))))
           
           (unless flag
             (displayln "Result: true")))...
           (unless (= 0 (length (list 'query ...)))
             (displayln (format "Model checking time: ~a ms" (round (- (current-inexact-milliseconds) start-time))))
             (displayln "*/=============================================================================\n")))]))

;writes the opening declarations for maude
(define (maude-opening)
  (add-maude-output "mod BITML-CONTRACT is\n protecting BITML .\n\n")
  (let* ([parts-dec (string-append "ops " (list+sep->string (get-participants) " ") " : -> Participant .\n")]
         [string-sec (map (lambda (x) (symbol->string x)) (get-secrets))]
         [string-vdep (map (lambda (x) (symbol->string x)) (get-volatile-deps))]
         [sec-dec (if (> (length string-sec) 0)
                      (string-append "ops " (list+sep->string string-sec " ") " : -> Secret .\n")
                      "")]
         [vdep-dec (if (> (length string-vdep) 0)
                       (string-append "ops " (list+sep->string string-vdep " ") " : -> Name .\n")
                       "")]
         [contract "op MContr : -> Contract .\n"]
         [sem-conf "op Cconf : -> SemConfiguration .\n"])
    (add-maude-output parts-dec sec-dec vdep-dec contract sem-conf)))

(define (get-maude-closing secrets-map)
  (let* ([sem-secrets (map
                       (lambda (s) (string-append " | { " (get-secret-part s) " : "
                                                  (symbol->string s) " # " (number->string (hash-ref secrets-map s)) " }"))
                       (get-secrets))]
         [sem-secret-dec (list+sep->string sem-secrets "")]
         [sem-vdeps (map (lambda (d) (let* ([vdep (get-volatile-dep d)]
                                            [part (first vdep)]
                                            [val (format-num (second vdep))])
                                       (string-append " | < " part ", " val " BTC > " (symbol->string d) " "))) (get-volatile-deps))]
         [sem-vdeps (list+sep->string sem-vdeps "")])
    
    (string-append "\neq Cconf = toSemConf < MContr , "
                   (format-num tx-v) " BTC > 'xconf\n"
                   sem-secret-dec "\n" sem-vdeps " .\n"
                   "endm\n"
                   "smod LIQUIDITY_CHECK is\nprotecting BITML-CHECK .\nincluding BITML-CONTRACT .\nendsm\n")))



(define-syntax (execute-maude-query stx)
  (syntax-parse stx
    #:literals (check-liquid check has-more-than check-query)
    [(_ secret-map (check-liquid strategy ...))
     #'(begin
         (let ([maude-str 
                (string-append maude-output
                               (compile-maude-strat strategy)...
                               (get-maude-closing secret-map)
                               "reduce in LIQUIDITY_CHECK : modelCheck(Cconf, <> contract-free, 'bitml) .\n"
                               "quit .\n")])
           (write-maude-file maude-str)
           (format-maude-out (execute-maude))))]
    
    [(_ secret-map (check part:string has-more-than val:number strategy ...))
     #'(begin
         (let ([maude-str 
                (string-append maude-output
                               (compile-maude-strat strategy)...
                               (get-maude-closing secret-map)
                               "reduce in LIQUIDITY_CHECK : modelCheck(Cconf, []<> " part
                               " has-deposit>= " (format-num val) " BTC, 'bitml) . \n"
                               "quit .\n")])
           (write-maude-file maude-str)
           (format-maude-out (execute-maude))))]
    [(_ secret-map (check-query query:string strategy ...))
     #'(begin
         (let ([maude-str 
                (string-append maude-output
                               (compile-maude-strat strategy)...
                               (get-maude-closing secret-map)
                               "reduce in LIQUIDITY_CHECK : modelCheck(Cconf, "
                               query ", 'bitml) . \n quit .\n")])
           (write-maude-file maude-str)
           (format-maude-out (execute-maude))))]))

(define-syntax (compile-maude-strat stx)
  (syntax-parse stx
    #:literals (strategy b-if)
    [(_ (strategy part:string action))
     #'(compile-maude-action part action)]
    [(_ (strategy part:string action b-if pred))
     #'(compile-maude-action part action b-if pred)]))

(define-syntax (compile-maude-action stx)
  (syntax-parse stx
    #:literals (b-if do-reveal do-auth not-destroy do-destroy)

    [(_ part:string (do-reveal secret:id) b-if pred)
     #'(string-append "eq strategy(ctx:Context S:Configuration" (compile-maude-pred pred)
                      ", " part " reveal " (symbol->string 'secret) ") = true . \n"
                      "eq strategy(ctx:Context S:Configuration , " part " lock-reveal " (symbol->string 'secret) ") = false .")]
    [(_ part:string (do-reveal secret:id))
     #'(string-append "eq strategy(S:SemConfiguration, " part " lock-reveal " (symbol->string 'secret) ") = false . \n")]  

    [(_ part:string (do-auth contract))
     #'(string-append "eq strategy(S:SemConfiguration, " part " lock " (compile-maude-contract contract strip-auth) " in x:Name) = false . \n")]
    [(_ part:string (do-auth contract) b-if pred)
     #'(string-append "eq strategy(S:SemConfiguration, " part " lock " (compile-maude-contract contract strip-auth) " in x:Name) = false . \n"
                      "eq strategy(ctx:Context S:Configuration " (compile-maude-pred pred)
                      ", " part " authorize " (compile-maude-contract contract strip-auth) " in x:Name) = true . \n"
                      "eq strategy(S:SemConfiguration, " part " authorize " (compile-maude-contract contract strip-auth) " in x:Name) = false .")]

    
    [(_ part:string (not-destroy vol-deposit))
     #'(string-append "eq strategy(S:SemConfiguration, " part " authorize-destroy-of " (symbol->string 'vol-deposit) ") = false .\n")]
    [(_ part:string (do-destroy vol-deposit))
     #'(string-append "eq strategyS:SemConfiguration, " part " authorize-destroy-of " (symbol->string 'vol-deposit) ") = true .\n")]))

;eq strategy(ctx:Context S:Configuration | B : b # 1, A authorize-destroy-of x) = false .
(define-syntax (compile-maude-pred stx)
  (syntax-parse stx
    #:literals (do-reveal do-auth not-destroy do-destroy state)
    [(_ (part:string do-reveal secret:id))
     #'(string-append " | " part " : " (symbol->string 'secret) " # 1 ")]
    [(_ (part:string do-auth contract))
     #'(string-append " | " part " [ x:Name |> " (compile-maude-contract contract) " ] ")]))

(define (write-maude-file str)
  (define out (open-output-file "test.maude" #:exists 'replace))
  (display str out)
  (close-output-port out))

(define (execute-maude)
  (let ([maude-path (environment-variables-ref (current-environment-variables) #"MAUDE_PATH")]
        (maude-mc-path (environment-variables-ref (current-environment-variables) #"MAUDE_MC_PATH"))
        (bitml-maude-path (environment-variables-ref (current-environment-variables) #"BITML_MAUDE_PATH")))
    
    (with-output-to-string (lambda ()
                             (system (format "~a/maude ~a/model-checker.maude ~a/bitml.maude test.maude"
                                             maude-path maude-mc-path bitml-maude-path) #:set-pwd? #t)))))

(define (format-maude-out str)
  (match (string-replace (string-replace str "\n" "") "\t" "")
    [(regexp #px"rewrites:.* \\((.*) real\\).*result ModelCheckResult: (counterexample\\(.*\\))Bye" (list _ time cex))
     ;(displayln (string-append "Computation time: " time))
     ;(displayln "Result: false\n")
     ;(displayln cex)
     (cons #f cex)]
    [(regexp #px"rewrites:.* \\((.*) real\\).*(result Bool: true.*)Bye" (list _ time res))
     ;(displayln (string-append "Computation time: " time))
     ;(displayln "Result: true")
     (cons #t "")]
    [x ;(displayln (string-append "Error: " x))
     (cons #f (string-append "Error: " x))]))

(define-syntax (compile-maude-contract stx)
  (syntax-parse stx
    #:literals (withdraw after auth split putrevealif pred sum strip-auth tau put reveal revealif)
    [(_ (withdraw part:string))
     #'(string-append "withdraw " part)]
    [(_ (after t (contract params ...)))
     #'(format "after ~a : ~a" t (compile-maude-contract (contract params ...)))]
    [(_ (auth part:string ... (contract params ...)))
     #'(string-append "(" (list+sep->string (list part ...) " , ") ") : " (compile-maude-contract (contract params ...)))]
    [(_ (auth part:string ... (contract params ...)) strip-auth)
     #'(compile-maude-contract (contract params ...))]

    [(_ (split (val:number -> (contract params ...))... ))
     #'(let* ([vals (list (format-num val) ...)]
              [g-contracts (list (compile-maude-contract (contract params ...)) ...)]
              [decl-parts (map
                           (lambda (v gc) (string-append v " BTC ~> ( " gc " )"))
                           vals
                           g-contracts)]
              [decl (list+sep->string decl-parts "\n")])
           
         (string-append "split( " decl " )" ))]

    [(_ (sum (contract params ...)...))
     #'(let ([g-contracts (list (compile-maude-contract (contract params ...))...)])         
         (string-append "( " (list+sep->string g-contracts " + ") " )"))]

    [(_ (putrevealif (tx-id:id ...) (sec:id ...) (~optional (pred p)) (contract params ...)))
     #'(let* ([txs (list (symbol->string 'tx-id) ...)]
              [secs (list (symbol->string 'sec) ...)]
              [txs-len (length txs)]
              [secs-len (length secs)]
              [compiled-pred (~? (string-append " if " (compile-pred-maude p)) "")]
              [compiled-cont (compile-maude-contract (contract params ...))])
         
         (if (and (= 0 secs-len) (> txs-len 0))
             (string-append "( put (" (list+sep->string txs) ") . " compiled-cont " )")
             (if (and (> secs-len 0) (= txs-len 0))
                 (string-append "( reveal (" (list+sep->string secs) ")" compiled-pred " . " compiled-cont " )")
                 (if (and (> secs-len 0) (> txs-len 0))
                     (string-append "( put (" (list+sep->string txs) ") reveal (" (list+sep->string secs) ")" compiled-pred " . " compiled-cont " )")
                     ""))))]

    [(_ (reveal (sec:id ...) (contract params ...)))
     #'(compile-maude-contract (putrevealif () (sec ...) (contract params ...)))]

    [(_ (revealif (sec:id ...) (pred p) (contract params ...)))
     #'(compile-maude-contract (putrevealif () (sec ...) (pred p) (contract params ...)))]

    [(_ (put (tx:id ...) (contract params ...)))
     #'(compile-maude-contract (putrevealif (tx ...) () (contract params ...)))]

    [(_ (tau (contract params ...)))
     #'(string-append "tau . ( " (compile-maude-contract (contract params ...)) " )")]))

(define (format-num n)
  (number->string (exact-floor (* n (expt 10 8)))))
