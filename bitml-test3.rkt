#lang s-exp "main.rkt"

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(key "A" (auth "A" "B" (after 30 (after 20 (withdraw "B")))) "02ec5dfd983a0a4e188be4581847e2ffd3639dc1c94a2ee2ee6d4d560fa6c35b31")
(key "B" (auth "A" "B" (after 30 (after 20 (withdraw "B")))) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")

(key "B" (withdraw "B") "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "A" (withdraw "B") "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")



(compile (guards (deposit "A" 1 "txA@0")
                   (deposit "A" 1 "txA1@0")
                   (deposit "B" 2 "txB@0"))
           (auth "A" "B" (after 30 (after 20 (withdraw "B")))))