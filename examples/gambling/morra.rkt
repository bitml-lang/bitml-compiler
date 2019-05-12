#lang bitml

(debug-mode)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(define (C) (choice
           (reveal (a) (choice
                        (reveal (b) (ref (C1)))
                        (after 500000 (withdraw "A"))))
           (reveal (b) (choice
                        (reveal (a) (ref (C1)))
                        (after 500000 (withdraw "B"))))
           (after 500000 (split (1 -> (withdraw "A")) (1 -> (withdraw "B"))))))

(define (C1) (choice
            (reveal (a1) (choice
                          (reveal (b1) (ref (W)))
                          (after 501000 (withdraw "A"))))
            (reveal (b1) (choice
                          (reveal (a1) (ref (W)))
                          (after 501000 (withdraw "B"))))
            (after 501000 (split (1 -> (withdraw "A")) (1 -> (withdraw "B"))))))

(define (W1) (choice
            (revealif (a b a1 b1) (pred (and (= a1 (+ a b)) (!= a b))) (withdraw "A"))
            (revealif (a b a1 b1) (pred (and (= b1 (+ a b)) (!= a b))) (withdraw "B"))
            (revealif (a b a1 b1) (pred (or
                                         (and (!= b1 (+ a b)) (!= a1 (+ a b)))
                                         (= a b)))
                      (split (1 -> (withdraw "A")) (1 -> (withdraw "B"))))))

(define (W) (choice
           (revealif (a b a1 b1) (pred (!= a1 b1)) (choice
                                                    (revealif (a b a1 b1) (pred (= a1 (+ a b))) (withdraw "A"))
                                                    (revealif (a b a1 b1) (pred (= b1 (+ a b))) (withdraw "B"))))
           (revealif (a b a1 b1) (pred (= a1 b1))
                     (split (1 -> (withdraw "A")) (1 -> (withdraw "B"))))))

(contract (pre
           (deposit "A" 1 "txA@0") (deposit "B" 1 "txB@0")
           (secret "B" b "f9292914bfd27c426a23465fc122322abbdb63b7")
           (secret "A" a "9804ebb0fc4a8329981dd33aaff32b6cb579580a")
           (secret "B" b1 "183c86e0a286ac99ad8cf5c4cde36511181ffbd5")
           (secret "A" a1 "14f06dde2fa12bd359ea0847de296f7b66a0f93f"))        

          (ref (C))
                   

          (check-liquid
           (secrets ((b  44) (a  44) (b1  44) (a1  44))
                    ((b  44) (a  44) (b1  44) (a1  48))
                    ((b  44) (a  44) (b1  88) (a1  44))
                    ((b  44) (a  44) (b1  44) (a1  88)))))