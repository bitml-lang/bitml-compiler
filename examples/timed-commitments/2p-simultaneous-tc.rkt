#lang bitml

(participant "A0" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "A1" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(debug-mode)

(define C00 (choice (reveal (a0) (ref C11)) (after 10 (tau (ref C10)))))

(define C11 (choice (reveal (a1) (ref W3)) (after 20 (ref W1))))

(define C10 (choice (reveal (a1) (ref W2)) (after 20 (ref W0))))

(define W0 
  (split (1 -> (withdraw "A0"))(1 -> (withdraw "A1"))))

(define W1
  (split (2.0 -> (withdraw "A0"))))

(define W2
  (split (2.0 -> (withdraw "A1"))))

(define W3
  (split (1.0 -> (withdraw "A0"))(1.0 -> (withdraw "A1"))))

(contract
 (pre (deposit "A0" 1 "txA@0")(secret "A0" a0 "000a")
      (deposit "A1" 1 "txB@0")(secret "A1" a1 "000b"))
 (ref C00)

 (check-liquid)
 
 (check-query "[]<> ~(a0 revealed) /\\ a1 revealed -> (A1 has-deposit>= 200000000 BTC /\\ A0 has-deposit<= 0 BTC)")
 
 (check "A0" has-more-than 1
        (strategy "A0" (do-reveal a0))))