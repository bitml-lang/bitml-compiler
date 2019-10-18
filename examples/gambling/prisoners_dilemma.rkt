#lang bitml

(debug-mode)

(participant "A" "pkA")
(participant "B" "pkB")
(participant "C" "pkC")


;; Model of the prisoner's dilemma in BitML
;
;  Moves
;  Defect -> 0
;  Coop   -> 1
;
; Payoffs
;      0      1
;   -------------
;   |   -1|    1|
; 0 |     |     |
;   |-1   |-1   |
;   -------------
;   |   -1|    0|
; 1 |     |     |
;   |1    |0    |
;   -------------

(define (Splits)
  (split
   (1 -> (withdraw "A"))
   (1 -> (withdraw "B"))))

(contract (pre
           (deposit "A" 3 "txA@0")(secret "A" a "18ed15665ab53ba8f4c965748e8a657cf40ee3f2")
           (deposit "B" 3 "txB@0")(secret "B" b "ded836a730cdeca5223f2609747074585f933aa8"))
         
          (split
           (2 -> (choice
                  (revealif (b) (pred (between b 0 1)) (withdraw "B"))
                  (after 10 (withdraw "A"))))
           (2 -> (choice
                  (reveal (a) (withdraw "A"))
                  (after 10 (withdraw "B"))))
           
           (2 -> (choice
                  (revealif (a) (pred (= a 0)) ;A defects
                            (choice
                             (revealif (b) (pred (= b 0)) (withdraw "C"))  ;B defects
                             (revealif (b) (pred (= b 1)) (withdraw "B"))) ;B coops
                            )
                  (revealif (a) (pred (= a 1)) ;A coops
                            (choice
                             (revealif (b) (pred (= b 0)) (withdraw "A"))  ;B defects
                             (revealif (b) (pred (= b 1)) (ref (Splits))) ;B coops
                             ))))))
