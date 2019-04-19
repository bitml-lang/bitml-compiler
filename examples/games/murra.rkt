#lang bitml

(debug-mode)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(define C (sum
           (reveal (a) (sum
                        (reveal (b) (ref C1))
                        (after 500000 (withdraw "A"))))
           (reveal (b) (sum
                        (reveal (a) (ref C1))
                        (after 500000 (withdraw "B"))))
           (after 500000 (split (1 -> (withdraw "A")) (1 -> (withdraw "B"))))))

(define C1 (sum
            (reveal (a1) (sum
                          (reveal (b1) (ref W))
                          (after 501000 (withdraw "A"))))
            (reveal (b1) (sum
                          (reveal (a1) (ref W))
                          (after 501000 (withdraw "B"))))
            (after 501000 (split (1 -> (withdraw "A")) (1 -> (withdraw "B"))))))

(define W1 (sum
            (revealif (a b a1 b1) (pred (and (= a1 (+ a b)) (!= a b))) (withdraw "A"))
            (revealif (a b a1 b1) (pred (and (= b1 (+ a b)) (!= a b))) (withdraw "B"))
            (revealif (a b a1 b1) (pred (or
                                         (and (!= b1 (+ a b)) (!= a1 (+ a b)))
                                         (= a b)))
                      (split (1 -> (withdraw "A")) (1 -> (withdraw "B"))))))

(define W (sum
           (revealif (a b a1 b1) (pred (!= a1 b1)) (sum
                                                    (revealif (a b a1 b1) (pred (= a1 (+ a b))) (withdraw "A"))
                                                    (revealif (a b a1 b1) (pred (= b1 (+ a b))) (withdraw "B"))))
           (revealif (a b a1 b1) (pred (= a1 b1))
                     (split (1 -> (withdraw "A")) (1 -> (withdraw "B"))))))

(contract (pre
           (deposit "A" 1 "txA@0") (deposit "B" 1 "txB@0")
           (secret "B" b "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35")
           (secret "A" a "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b")
           (secret "B" b1 "e4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35")
           (secret "A" a1 "fb86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b"))        

          (ref C)
                   

          (check-liquid))