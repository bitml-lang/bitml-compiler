#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(generate-keys)



(contract (guards (deposit "A" 4 "txA@0")(secret "A" a "000a")(secret "B" b "000b")(deposit "B" 0 "txB@0"))        
         (after 10 (split
                    (3 -> (sum  (putrevealif () (a)  (withdraw "A"))
                            (withdraw "B")))
                    (1 -> (sum (withdraw "B"))))))

