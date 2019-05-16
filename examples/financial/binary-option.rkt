#lang bitml


(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")
(participant "O" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")

(debug-mode)
;(verification-only)

(define (txA) "txid:something@0")

;; A receives 1 BTC if a predefined event took place at t0 and nothing otherwise.
;; Modelled as an Oracle contract

(define (BinaryOption)
  (choice
   (auth "O" (withdraw "A"))
   (auth "O" (withdraw "B"))))

(contract
 (pre (deposit "A" 1 (ref (txA))))
 
 (ref (BinaryOption))
 
 (check-liquid
  (strategy "O" (do-auth))))