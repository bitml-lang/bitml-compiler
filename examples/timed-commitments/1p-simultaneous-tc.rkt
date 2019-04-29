#lang bitml

(participant "A0" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")

(debug-mode)

(define (C00) (choice (reveal (a0) (ref (W1))) (after 10 (ref (W0)))))

(define (W0)
 (split (1 -> (withdraw "A0"))))

(define (W1)
 (split (1.0 -> (withdraw "A0"))))

(contract
 (pre (deposit "A0" 1 "txA@0")(secret "A0" a0 "000a"))
 (ref (C00))
 (check-liquid))