#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")
(participant "M" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(define (txA1) "txid:something@0")
(define (txA2) "txid:somethingelse@0")
(define (txB) "txid:somethingmore@0")

(define (Resolve) (split
                 (0.1 -> (withdraw "M"))
                 (1 -> (choice
                        (auth "M" (withdraw "B"))
                        (auth "M" (withdraw "A"))))))

(contract
 (pre (deposit "A" 1 (ref (txA1)))
      (vol-deposit "A" x 0.05 (ref (txA2)))
      (vol-deposit "B" y 0.05 (ref (txB))))
 (choice
  (auth "A" (withdraw "B"))
  (auth "B" (withdraw "A"))
  (after 500000 (withdraw "B"))
  (put (x) (choice
            (put (y) (ref (Resolve)))
            (after 501000 (withdraw "A")))))

 (check-liquid
  (strategy "M" (do-auth (auth "M" (withdraw "B"))))))