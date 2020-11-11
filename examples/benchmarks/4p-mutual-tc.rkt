#lang bitml

(participant "A0" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "A1" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "A2" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af31")
(participant "A3" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af33")

(debug-mode)

(define (C00) (choice (reveal (a0) (ref (C11))) (after 10 (tau (ref (C10))))))

(define (C11) (choice (reveal (a1) (ref (C23))) (after 20 (tau (ref (C21))))))

(define (C23) (choice (reveal (a2) (ref (C37))) (after 30 (tau (ref (C33))))))

(define (C37) (choice (reveal (a3) (ref (W15))) (after 40 (ref (W7)))))

(define (C33) (choice (reveal (a3) (ref (W11))) (after 40 (ref (W3)))))

(define (C21) (choice (reveal (a2) (ref (C35))) (after 30 (tau (ref (C31))))))

(define (C35) (choice (reveal (a3) (ref (W13))) (after 40 (ref (W5)))))

(define (C31) (choice (reveal (a3) (ref (W9))) (after 40 (ref (W1)))))

(define (C10) (choice (reveal (a1) (ref (C22))) (after 20 (tau (ref (C20))))))

(define (C22) (choice (reveal (a2) (ref (C36))) (after 30 (tau (ref (C32))))))

(define (C36) (choice (reveal (a3) (ref (W14))) (after 40 (ref (W6)))))

(define (C32) (choice (reveal (a3) (ref (W10))) (after 40 (ref (W2)))))

(define (C20) (choice (reveal (a2) (ref (C34))) (after 30 (tau (ref (C30))))))

(define (C34) (choice (reveal (a3) (ref (W12))) (after 40 (ref (W4)))))

(define (C30) (choice (reveal (a3) (ref (W8))) (after 40 (ref (W0)))))

(define (W0) 
  (split (1 -> (withdraw "A0"))(1 -> (withdraw "A1"))(1 -> (withdraw "A2"))(1 -> (withdraw "A3"))))

(define (W1)
  (split (4.0 -> (withdraw "A0"))))

(define (W2)
  (split (4.0 -> (withdraw "A1"))))

(define (W3)
  (split (2.0 -> (withdraw "A0"))(2.0 -> (withdraw "A1"))))

(define (W4)
  (split (4.0 -> (withdraw "A2"))))

(define (W5)
  (split (2.0 -> (withdraw "A0"))(2.0 -> (withdraw "A2"))))

(define (W6)
  (split (2.0 -> (withdraw "A1"))(2.0 -> (withdraw "A2"))))

(define (W7)
  (split (1.34 -> (withdraw "A0"))(1.33 -> (withdraw "A1"))(1.33 -> (withdraw "A2"))))

(define (W8)
  (split (4.0 -> (withdraw "A3"))))

(define (W9)
  (split (2.0 -> (withdraw "A0"))(2.0 -> (withdraw "A3"))))

(define (W10)
  (split (2.0 -> (withdraw "A1"))(2.0 -> (withdraw "A3"))))

(define (W11)
  (split (1.34 -> (withdraw "A0"))(1.33 -> (withdraw "A1"))(1.33 -> (withdraw "A3"))))

(define (W12)
  (split (2.0 -> (withdraw "A2"))(2.0 -> (withdraw "A3"))))

(define (W13)
  (split (1.34 -> (withdraw "A0"))(1.33 -> (withdraw "A2"))(1.33 -> (withdraw "A3"))))

(define (W14)
  (split (1.34 -> (withdraw "A1"))(1.33 -> (withdraw "A2"))(1.33 -> (withdraw "A3"))))

(define (W15)
  (split (1.0 -> (withdraw "A0"))(1.0 -> (withdraw "A1"))(1.0 -> (withdraw "A2"))(1.0 -> (withdraw "A3"))))

(contract
 (pre (deposit "A0" 1 "txA@0")(secret "A0" a0 "000a")
      (deposit "A1" 1 "txB@0")(secret "A1" a1 "000b")
      (deposit "A2" 1 "txC@0")(secret "A2" a2 "000c")
      (deposit "A3" 1 "txD@0")(secret "A3" a3 "000d"))
 
 (ref (C00))

 (check-liquid))