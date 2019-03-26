#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "C" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "D" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")


(generate-keys)

(define C00 (reveal (a) (sum (ref C11) (after 10 (ref C10)))))


(define C11 (reveal (b) (sum (ref C23) (after 20 (ref C21)))))


(define C23 (reveal (c) (sum (ref C37) (after 30 (ref C33)))))


(define C37 (reveal (d) (sum (ref W15) (after 40 (ref W7)))))


(define C33 (reveal (d) (sum (ref W11) (after 40 (ref W3)))))


(define C21 (reveal (c) (sum (ref C35) (after 30 (ref C31)))))


(define C35 (reveal (d) (sum (ref W13) (after 40 (ref W5)))))


(define C31 (reveal (d) (sum (ref W9) (after 40 (ref W1)))))


(define C10 (reveal (b) (sum (ref C22) (after 20 (ref C20)))))


(define C22 (reveal (c) (sum (ref C36) (after 30 (ref C32)))))


(define C36 (reveal (d) (sum (ref W14) (after 40 (ref W6)))))


(define C32 (reveal (d) (sum (ref W10) (after 40 (ref W2)))))


(define C20 (reveal (c) (sum (ref C34) (after 30 (ref C30)))))


(define C34 (reveal (d) (sum (ref W12) (after 40 (ref W4)))))


(define C30 (reveal (d) (sum (ref W8) (after 40 (ref W0)))))


(define W0 
 (split (1 -> (withdraw "A"))(1 -> (withdraw "B"))(1 -> (withdraw "C"))(1 -> (withdraw "D"))))

(define W1
 (split (4.0 -> (withdraw "A"))))

(define W2
 (split (4.0 -> (withdraw "B"))))

(define W3
 (split (2.0 -> (withdraw "A"))(2.0 -> (withdraw "B"))))

(define W4
 (split (4.0 -> (withdraw "C"))))

(define W5
 (split (2.0 -> (withdraw "A"))(2.0 -> (withdraw "C"))))

(define W6
 (split (2.0 -> (withdraw "B"))(2.0 -> (withdraw "C"))))

(define W7
 (split (1.33333333333 -> (withdraw "A"))(1.33333333333 -> (withdraw "B"))(1.33333333333 -> (withdraw "C"))))

(define W8
 (split (4.0 -> (withdraw "D"))))

(define W9
 (split (2.0 -> (withdraw "A"))(2.0 -> (withdraw "D"))))

(define W10
 (split (2.0 -> (withdraw "B"))(2.0 -> (withdraw "D"))))

(define W11
 (split (1.33333333333 -> (withdraw "A"))(1.33333333333 -> (withdraw "B"))(1.33333333333 -> (withdraw "D"))))

(define W12
 (split (2.0 -> (withdraw "C"))(2.0 -> (withdraw "D"))))

(define W13
 (split (1.33333333333 -> (withdraw "A"))(1.33333333333 -> (withdraw "C"))(1.33333333333 -> (withdraw "D"))))

(define W14
 (split (1.33333333333 -> (withdraw "B"))(1.33333333333 -> (withdraw "C"))(1.33333333333 -> (withdraw "D"))))

(define W15
 (split (1.0 -> (withdraw "A"))(1.0 -> (withdraw "B"))(1.0 -> (withdraw "C"))(1.0 -> (withdraw "D"))))

(contract
 (guards (deposit "A" 1 "txA@0")(secret "A" a "000a")
         (deposit "B" 1 "txB@0")(secret "B" b "000b")
         (deposit "C" 1 "txC@0")(secret "C" c "000c")
         (deposit "D" 1 "txC@0")(secret "D" d "000d"))
 
 (ref C00)

 (check-liquid))