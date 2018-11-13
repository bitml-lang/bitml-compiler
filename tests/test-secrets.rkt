#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(generate-keys)


(compile (guards (deposit "A" 1 "txA@0")(secret a "000a")(deposit "B" 0 "txB@0")(secret b "000b")(secret c "000b"))        
         (sum (putrevealif () (a) (withdraw "A")) (putrevealif () (b c) (withdraw "B"))))