#lang bitml

(participant "A" "aKey")
(participant "B" "bKey")

(define (txA) "txA")

(define (X n)
  (tau (choice
   (reveal (a) (withdraw "A"))
   (rec (X "n"))
   )))

(debug-mode)

(contract
 (pre (deposit "A" 0.00453333 (ref (txA)))
      (secret "A" a "9f3df038eeadc0c240fb7f82e31fdfe46804fc7c"))
 
 (choice (reveal (a) (withdraw "A"))
      (after 1550000 (withdraw "B"))
      (rngt (X "n")))

 (check-liquid)

 )

