#lang s-exp "../main.rkt"

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(key "A" (sum (putrevealif () (a) (sum (withdraw "A") (withdraw "B"))) (after 10 (withdraw "B"))) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "B" (sum (putrevealif () (a) (sum (withdraw "A") (withdraw "B"))) (after 10 (withdraw "B"))) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "A" (putrevealif () (a) (sum (withdraw "A") (withdraw "B"))) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "B" (putrevealif () (a) (sum (withdraw "A") (withdraw "B"))) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "A" (after 10 (withdraw "B")) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "B" (after 10 (withdraw "B")) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "A" (sum (withdraw "A") (withdraw "B")) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "B" (sum (withdraw "A") (withdraw "B")) "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "A" (withdraw "A") "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "B" (withdraw "A") "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "A" (withdraw "B") "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
(key "B" (withdraw "B") "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")



(compile (guards (deposit "A" 1 "txA@0")(secret a "000a")(deposit "B" 0 "txB@0"))        
         (sum (putrevealif () (a) (sum (withdraw "A") (withdraw "B"))) (after 10 (withdraw "B"))))

