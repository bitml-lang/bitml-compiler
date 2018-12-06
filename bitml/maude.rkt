#lang racket/base

(require "string-helpers.rkt")

(define maude-output "")

(define (add-maude-output . str-list )
  (set! maude-output (string-append maude-output (list+sep->string str-list "") "\n" )))

;writes the opening declarations for maude
(define (maude-opening participants secrets)
  (add-maude-output "mod Contract is\n protecting BITML .\n\n")
  (let* ([parts-dec (string-append "ops " (list+sep->string participants " ") " : -> Participant .\n")]
         [string-sec (map (lambda (x) (symbol->string x)) secrets)]
         [sec-dec (string-append "ops " (list+sep->string string-sec " ") " : -> Secret .\n")]
         [contract "op S : Contract -> SemConfiguration .\n"])
    
    (add-maude-output parts-dec sec-dec contract)))

(provide (all-defined-out))