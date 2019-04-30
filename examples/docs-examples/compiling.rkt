#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(define (txA) "txa@1")
(define (txFee) "txaf@1")


(contract
 (pre (deposit "A" 0.01 (ref (txA)))
      (fee "A" 0.01 (ref (txFee))))
 (withdraw "B"))