#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/list racket/port racket/system
         "string-helpers.rkt" "env.rkt" "terminals.rkt")

(define maude-output "")

(define (add-maude-output . str-list )
  (set! maude-output (string-append maude-output (list+sep->string str-list "") "\n" )))

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
         [contract "op C : -> Contract .\n"]
         [sem-conf "op Cconf : -> SemConfiguration .\n"]
         )
    (add-maude-output parts-dec sec-dec vdep-dec contract sem-conf)))

(provide (all-defined-out))

(define (maude-closing)
  (let* ([sem-secrets (map (lambda (s) (string-append " | { " (get-secret-part s) " : " (symbol->string s) " # 1 }")) (get-secrets))]
         [sem-secret-dec (list+sep->string sem-secrets "")]
         [sem-vdeps (map (lambda (d) (let* ([vdep (get-volatile-dep d)]
                                            [part (first vdep)]
                                            [val (number->string (second vdep))])
                                       (string-append " | < " part ", " val " BTC > " (symbol->string d) " "))) (get-volatile-deps))]
         [sem-vdeps (list+sep->string sem-vdeps "")])
    
    (add-maude-output (string-append "\neq Cconf = toSemConf < C , "
                                     (number->string tx-v) " BTC > 'xconf\n"
                                     sem-secret-dec "\n" sem-vdeps " .\n"))
    (add-maude-output "endm\n")
    (add-maude-output "smod LIQUIDITY_CHECK is\nprotecting BITML-CHECK .\nincluding BITML-CONTRACT .\nendsm\n")))



(define-syntax (compile-maude-query stx)
  (syntax-parse stx
    #:literals (check-liquid check has-more-than)
    [(_ (check-liquid strategy ...))
     #'(begin
         (for ([s (list strategy ...)])
           (add-maude-output (compile-maud-strat s)))
         (maude-closing)
         (string-append "reduce in LIQUIDITY_CHECK : modelCheck(Cconf, <> contract-free, 'bitml) .\n")
         (add-maude-output "quit .\n")
         (write-maude-file)
         (displayln (execute-maude)))]
    
    [(_ (check part:string has-more-than val:number strategy ...))
     #'(begin
         (add-maude-output (compile-maude-strat strategy))...
         (maude-closing)
         (add-maude-output "reduce in LIQUIDITY_CHECK : modelCheck(Cconf, []<> " part
                           " has-deposit>= " (number->string val) " BTC, 'bitml) . \n")
         (add-maude-output "quit .\n")
         (write-maude-file)
         (display "/*\nModel checking result for ")
         (displayln '(check part has-more-than val strategy ...))
         (displayln (execute-maude))
         (display "*/"))]))

(define-syntax (compile-maude-strat stx)
  (syntax-parse stx
    #:literals (strategy b-if)
    [(_ (strategy part:string action))
     #'(compile-maude-action part action)]
    [(_ (strategy part:string action b-if pred))
     #'(compile-maude-action part action b-if pred)]))

(define-syntax (compile-maude-action stx)
  (syntax-parse stx
    #:literals (b-if do-reveal do-auth not-destory)

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

    
    [(_ part:string (not-destory vol-deposit))
     #'(string-append "eq strategy(S:SemConfiguration, " part " authorize-destroy-of " (symbol->string 'vol-deposit) ") = false .\n")]
    [(_ part:string (do-destory vol-deposit))
     #'(string-append "eq strategyS:SemConfiguration, " part " authorize-destroy-of " (symbol->string 'vol-deposit) ") = true .\n")]))

;eq strategy(ctx:Context S:Configuration | B : b # 1, A authorize-destroy-of x) = false .
(define-syntax (compile-maude-pred stx)
  (syntax-parse stx
    #:literals (do-reveal do-auth not-destory do-destory state)
    [(_ (part:string do-reveal secret:id))
     #'(string-append " | " part " : " (symbol->string 'secret) " # 1 ")]
    [(_ (part:string do-auth contract))
     #'(string-append " | " part " [ x:Name |> " (compile-maude-contract contract) " ] ")]))

(define (write-maude-file)
  (define out (open-output-file "test.maude" #:exists 'replace))
  (display maude-output out)
  (close-output-port out))

(define (execute-maude)
  (let ([maude-path (environment-variables-ref (current-environment-variables) #"MAUDE-PATH")]
        (maude-mc-path (environment-variables-ref (current-environment-variables) #"MAUDE-MC-PATH"))
        (bitml-maude-path (environment-variables-ref (current-environment-variables) #"BITML-MAUDE-PATH")))
  (if (equal? (system-type) 'windows)
      (with-output-to-string (lambda ()
                               (system (format "~a/maude.exe ~a/model-checker.maude ~a/bitml.maude test.maude"
                                               maude-path maude-mc-path bitml-maude-path) #:set-pwd? #t)))
      (with-output-to-string (lambda ()
                               (system (format "~a/maude.exe ~a/model-checker.maude ~a/bitml.maude test.maude"
                                               maude-path maude-path bitml-maude-path) #:set-pwd? #t))))))