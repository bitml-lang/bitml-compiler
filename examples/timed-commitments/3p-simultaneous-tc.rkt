#lang bitml

(participant "A0" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "A1" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "A2" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(debug-mode)

(define C00 (choice (reveal (a0) (ref C11)) (after 10 (tau (ref C10)))))

(define C11 (choice (reveal (a1) (ref C23)) (after 20 (tau (ref C21)))))

(define C23 (choice (reveal (a2) (ref W7)) (after 30 (ref W3))))

(define C21 (choice (reveal (a2) (ref W5)) (after 30 (ref W1))))

(define C10 (choice (reveal (a1) (ref C22)) (after 20 (tau (ref C20)))))

(define C22 (choice (reveal (a2) (ref W6)) (after 30 (ref W2))))

(define C20 (choice (reveal (a2) (ref W4)) (after 30 (ref W0))))

(define W0 
  (split (1 -> (withdraw "A0"))(1 -> (withdraw "A1"))(1 -> (withdraw "A2"))))

(define W1
  (split (3.0 -> (withdraw "A0"))))

(define W2
  (split (3.0 -> (withdraw "A1"))))

(define W3
  (split (1.5 -> (withdraw "A0"))(1.5 -> (withdraw "A1"))))

(define W4
  (split (3.0 -> (withdraw "A2"))))

(define W5
  (split (1.5 -> (withdraw "A0"))(1.5 -> (withdraw "A2"))))

(define W6
  (split (1.5 -> (withdraw "A1"))(1.5 -> (withdraw "A2"))))

(define W7
  (split (1.0 -> (withdraw "A0"))(1.0 -> (withdraw "A1"))(1.0 -> (withdraw "A2"))))

(contract
 (pre (deposit "A0" 1 "txA@0")(secret "A0" a0 "000a")
      (deposit "A1" 1 "txB@0")(secret "A1" a1 "000b")
      (deposit "A2" 1 "txC@0")(secret "A2" a2 "000c"))
 (ref C00)

 (check-liquid))