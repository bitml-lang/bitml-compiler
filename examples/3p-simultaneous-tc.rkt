#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "C" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(generate-keys)

(define C10 (reveal (b) (sum (ref C22)
                             (after 20 (ref C20)))))

(define C11 (reveal (b) (sum (ref C23)
                             (after 20 (ref C21)))))

(define C20 (reveal (c) (sum (ref W4)
                             (after 30 (ref W0)))))

(define C21 (reveal (c) (sum (ref W5)
                             (after 30 (ref W1)))))

(define C22 (reveal (c) (sum (ref W6)
                             (after 30 (ref W2)))))

(define C23 (reveal (c) (sum (ref W7)
                             (after 30 (ref W3)))))

(define W0 (split (1 -> (withdraw "A"))
                  (1 -> (withdraw "B"))
                  (1 -> (withdraw "C"))))

(define W1 (withdraw "A"))

(define W2 (withdraw "B"))

(define W3 (split (1.5 -> (withdraw "A"))
                  (1.5 -> (withdraw "B"))))

(define W4 (withdraw "C"))

(define W5 (split (1.5 -> (withdraw "A"))
                  (1.5 -> (withdraw "C"))))

(define W6 (split (1.5 -> (withdraw "B"))
                  (1.5 -> (withdraw "C"))))

(define W7 (split (1 -> (withdraw "A"))
                  (1 -> (withdraw "B"))
                  (1 -> (withdraw "C"))))


(contract
 (guards (deposit "A" 1 "txA@0")(secret "A" a "000a")
         (deposit "B" 1 "txB@0")(secret "B" b "000b")
         (deposit "C" 1 "txC@0")(secret "C" c "000c"))
 (sum
  (reveal (a) (ref C11))
  (after 10 (ref C10)))

 (check-liquid))