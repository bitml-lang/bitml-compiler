#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(debug-mode)


(contract (pre
           (deposit "A" 1 "txA@0")
           (deposit "B" 1 "txB@0")
           (vol-deposit "A" x 1 "txA@1"))        
          (put (x) (withdraw "B"))

          (check-liquid) ; should return false (put blocks if deposit x is destroyed)

          (check-query "(A has-deposit>= 100000000 satoshi)") ; should return true
                    
          (check-query "[] (<> A has-deposit>= 100000000 satoshi)") ; should return false

          )
