#lang bitml

(generate-keys)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(compile (guards
          (deposit "A" 3 "txA@0")(secret "A" a "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b")
          (deposit "B" 3 "txB@0")(secret "B" b "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35"))         
         
         (split
          (2 -> (sum
                 (revealif (b) (pred (and (<= 0 (size b)) (<= (size b) 2))) (withdraw "B"))
                 (after 10 (withdraw " A"))))
          (2 -> (sum
                 (reveal (a) (withdraw "A"))
                 (after 10 (withdraw "B"))))
          (2 -> (sum
                 (revealif (a b) (pred (= (size a) (size b)))
                           (split (1 -> (withdraw "A")) (1 -> (sum (withdraw "B")))))
                 
                 (revealif (a b) (pred (or (or (and (= (size a) 0) (= (size b) 2))
                                               (and (= (size a) 2) (= (size b) 1)))
                                           (and (= (size a) 1) (= (size b) 0))))
                           (withdraw "A"))
                 
                 (revealif (a b) (pred (or (or (and (= (size b) 0) (= (size a) 2))
                                               (and (= (size b) 2) (= (size a) 1)))
                                           (and (= (size b) 1) (= (size a) 0))))
                           (withdraw "B"))
                 )))

         (check-liquid))