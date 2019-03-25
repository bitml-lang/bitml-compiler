#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(generate-keys)

(define C10 (reveal (b) (sum (ref W2)
                             (after 20 (ref W0)))))

(define C11 (reveal (b) (sum (ref W0)
                             (after 20 (ref W1)))))

(define W0 (split (1 -> (withdraw "A"))
                  (1 -> (withdraw "B"))))

(define W1 (withdraw "A"))

(define W2 (withdraw "B"))

(contract
 (guards (deposit "A" 1 "txA@0")(secret "A" a "000a")
         (deposit "B" 1 "txB@0")(secret "B" b "000b"))
 (sum
  (reveal (a) (ref C11))
  (after 10 (ref C10)))

 (check-liquid))