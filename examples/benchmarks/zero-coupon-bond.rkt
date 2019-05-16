#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "I" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")
(participant "G" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)
;(verification-only)

(define (txA) "txid:something@0")
(define (txI) "txid:somethingelse@0")
(define (txG) "txid:somethingmore@0")

(define (ZCB maturity expiration)
  (split
   (0.9 -> (withdraw "I"))
   (1 -> (choice
          (after maturity (put (x) (split (1 -> (withdraw "A")) (1 -> (withdraw "G"))))) ; I pays the bond and G recovers his security deposit
          (after expiration (withdraw "A")) ; guarators pays the bond to A
          )))
  )

(contract
 (pre (deposit "A" 0.9 (ref (txA)))
      (vol-deposit "I" x 1 (ref (txI)))
      (deposit "G" 1 (ref (txG))))
 
 (ref (ZCB 1000 1100))
 
 (check-liquid))