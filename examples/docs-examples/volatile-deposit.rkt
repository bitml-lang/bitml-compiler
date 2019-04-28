#lang bitml

(participant "A1" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "A2" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(define txA1 "txid:something@0")
(define txA2 "txid:somethingelse@0")

(contract
 (pre (deposit "A1" 2 (ref txA1))
      (vol-deposit "A2" x 1 (ref txA2)))
 (choice
  (put (x) (split (2 -> (withdraw "B"))
                  (1 -> (withdraw "A1"))))
  (after 700000 (withdraw "B")))

 (check-liquid))