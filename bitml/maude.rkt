#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/list
         "string-helpers.rkt" "env.rkt")

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
    (add-maude-output "smod LIQUIDITY_CHECK is\nprotecting BITML-CHECK .\nincluding BITML-CONTRACT .\nendsm\n")
    (add-maude-output "reduce in LIQUIDITY_CHECK : modelCheck(Cconf, <> contract-free, 'bitml) .\n")
    (add-maude-output "quit .\n")))