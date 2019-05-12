#lang bitml

(debug-mode)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(contract (pre
          (deposit "A" 1 "txA@0")(secret "A" a "7249ab836ec75abf7756aec7528812a86a9f23df")
          (deposit "B" 1 "txB@0")(secret "B" b "de81500d472e6356185374ac8dc9a60b528b4a67"))        

         (choice
          (revealif (b) (pred (between b 0 1))
                    (choice
                     (revealif (a b) (pred (= a b)) (withdraw "A"))
                     (revealif (a b) (pred (!= a b)) (withdraw "B"))
                     (after 10 (withdraw "B"))))
          (after 10 (withdraw "A")))
                   

         (check-liquid)

         #;(check "A" has-at-least 1
                (strategy "A" (do-reveal a))))