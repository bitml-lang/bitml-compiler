#lang bitml

;; The investor Alice, invests 1 BTC,
;; and receives two coupon payments of 0.1 BTC
;; from the issuer I at regular intervals.
;; She also recover the bond at the maturity date.
;; A guarantor G guarantees Alice's investment, 
;; paying if the issuer fails to do so.

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "I" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")
(participant "G" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)
;(verification-only)

(define (txA) "txid:something@0")
(define (txI1) "txid:somethingelse@0")
(define (txI2) "txid:somethingels2e@0")
(define (txI3) "txid:somethingels3e@0")
(define (txG) "txid:somethingmore@0")

(define (CB firstInterval firstExpiration
            secondInterval secondExpiration
            maturity maturityExpiration)
  (split
   (1 -> (withdraw "I"))
   (0.1 -> (choice
            (after firstInterval (put (x)
                                      (split (0.1 -> (withdraw "A")) (0.1 -> (withdraw "G"))))) ; I pays the first coupon and G recovers his security deposit
            (after firstExpiration (withdraw "A"))                                              ; G pays the first coupon to A
            ))
   (0.1 -> (choice
            (after secondInterval (put (y)
                                       (split (0.1 -> (withdraw "A")) (0.1 -> (withdraw "G"))))) ; I pays the second coupon and G recovers his security deposit
            (after secondExpiration (withdraw "A"))                                              ; G pays the second coupon to A
            ))
   (1 -> (choice
          (after maturity (put (z)
                               (split (1 -> (withdraw "A")) (1 -> (withdraw "G")))))             ; I pays the bond and G recovers his security deposit
          (after maturityExpiration (withdraw "A"))                                              ; G pays the bond to A
          ))
   )
  )

(contract
 (pre (deposit "A" 1 (ref (txA)))
      (vol-deposit "I" x 0.1 (ref (txI1))) (vol-deposit "I" y 0.1 (ref (txI2))) (vol-deposit "I" z 1 (ref (txI3)))
      (deposit "G" 1.2 (ref (txG))))
 
 (ref (CB 1000 1100 1200 1300 1400 1500))
 
 (check-liquid))