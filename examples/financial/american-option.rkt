#lang bitml


(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "I" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")
(participant "G" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)
;(verification-only)

(define (txA) "txid:something@0")
(define (txI) "txid:somethingelse@0")
(define (txG) "txid:somethingmore@0")


;; parties agree to execute the Contract at before t
(define (Future t Contract)
  (choice
   (tau Contract)
   (after t (split (1 -> (withdraw "A")) (1 -> (withdraw "I")) (1 -> (withdraw "G"))))))

;; Part can choose at time t whether to execute Contract1 or Contract2
(define (AmericanOption Part t Contract1 Contract2)
  (choice
   (auth Part (tau (ref (Future t Contract1))))
   (auth Part (tau (ref (Future t Contract2))))))

(contract
 (pre (deposit "A" 1 (ref (txA))) (deposit "I" 1 (ref (txI))) (deposit "G" 1 (ref (txG))))
 
 (ref (AmericanOption "A" 1100 (withdraw "A") (withdraw "I")))
 
 (check-liquid
  (strategy "A" (do-auth))))