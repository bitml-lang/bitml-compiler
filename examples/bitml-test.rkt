#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(key "B" (withdraw "A") "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "A" (withdraw "A") "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "A" (putrevealif (x y) (a) (pred (= a 100)) (withdraw "A")) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "B" (putrevealif (x y) (a) (pred (= a 100)) (withdraw "A")) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")



(contract (pre (deposit "A" 1 "txA@0")(deposit "A" 1 "txA1@0")(deposit "B" 2 "txB")
                 (secret "A" a "000a")(secret "B" b "000b")
                 (vol-deposit "A" x 1 "txVA") (vol-deposit "B" y 1 "txVB"))
         
         (putrevealif (x y) (a) (pred (= a 100)) (withdraw "A")))

