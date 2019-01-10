#lang racket/base

(require (for-syntax racket/base syntax/parse)
         "string-helpers.rkt" "env.rkt")

(define maude-output "")

(define (add-maude-output . str-list )
  (set! maude-output (string-append maude-output (list+sep->string str-list "") "\n" )))

;writes the opening declarations for maude
(define (maude-opening)
  (add-maude-output "mod BITML-CONTRACT is\n protecting BITML .\n\n")
  (let* ([parts-dec (string-append "ops " (list+sep->string (get-participants) " ") " : -> Participant .\n")]
         [string-sec (map (lambda (x) (symbol->string x)) (get-secrets))]
         [sec-dec (string-append "ops " (list+sep->string string-sec " ") " : -> Secret .\n")]
         [contract "op C : -> Contract .\n"]
         [sem-conf "op Cconf : -> SemConfiguration .\n"]
         )
    (add-maude-output parts-dec sec-dec contract sem-conf)))

(provide (all-defined-out))

(define (maude-closing)
  (let* ([sem-secrets (map (lambda (s) (string-append " | { " (get-secret-part s) " : " (symbol->string s) " # 1 }")) (get-secrets))]
         [sem-secret-dec (list+sep->string sem-secrets "")])
    (add-maude-output (string-append "\neq Cconf = toSemConf < C , "
                                     (number->string tx-v) " BTC > 'x\n"
                                     sem-secret-dec " .\n"))
    (add-maude-output "endm\n")
    (add-maude-output "smod LIQUIDITY_CHECK is\nprotecting BITML-CHECK .\nincluding BITML-CONTRACT .\nendsm\n")
    (add-maude-output "reduce in LIQUIDITY_CHECK : modelCheck(Cconf, <> contract-free, 'bitml) .\n")))