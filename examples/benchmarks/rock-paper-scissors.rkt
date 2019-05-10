#lang bitml

(debug-mode)

(auto-generate-secrets)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

; 0 = rock
; 1 = paper
; 2 = scissors
;
; a\b | 0 | 1 | 2
;   0 | - | B | A
;   1 | A | - | B
;   2 | B | A | -

(contract (pre
          (deposit "A" 3 "txA@0")(secret "A" a "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b")
          (deposit "B" 3 "txB@0")(secret "B" b "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35"))
         (split
          (2 -> (choice
                 (revealif (b) (pred (between b 0 2)) (withdraw "B"))
                 (after 10 (withdraw " A"))))
          (2 -> (choice
                 (reveal (a) (withdraw "A"))
                 (after 10 (withdraw "B"))))
          (2 -> (choice
                 (revealif (a b) (pred (= a b))
                           (split (1 -> (withdraw "A")) (1 -> (choice (withdraw "B"))))) ; tie
                 
                 (revealif (a b) (pred (and (= a 0) (= b 2))) (withdraw "A")) ; A=rock, B=scissors
                 (revealif (a b) (pred (and (= a 1) (= b 0))) (withdraw "A")) ; A=paper, B=rock
                 (revealif (a b) (pred (and (= a 2) (= b 1))) (withdraw "A")) ; A=scissors, B=paper

                 (revealif (a b) (pred (and (= a 2) (= b 0))) (withdraw "B")) ; A=scissors, B=rock
                 (revealif (a b) (pred (and (= a 0) (= b 1))) (withdraw "B")) ; A=rock, B=paper
                 (revealif (a b) (pred (and (= a 1) (= b 2))) (withdraw "B")) ; A=paper, B=scissors

                 (after 1000 (split (1 -> (withdraw "A")) (1 -> (choice (withdraw "B"))))) ; timeout
                 )))

         (check-liquid))