#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "I" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(define (txA) ".")
(define (txFee) "..")
(define (txI) "...")


;; Part can choose at time t whether to execute Contract1 or Contract2
;; after deadline t, the contract Default can be executed
;--------------------------------------------------------------
(define (AmericanOption Part t Contract1 Contract2 Default)
  (choice
   (auth Part (tau (ref (Contract1))))
   (auth Part (tau (ref (Contract2))))
   (after t (tau (ref (Default))))))

; Sub-contracts used to instantiate the American Option
;--------------------------------------------------------------

;; A chooses not to proceed with the investment,
;; and gets back her deposit minus a cancellation fee.
;; I gets gets the fee from A.
(define (Retract)
  (split
   (0.95 -> (withdraw "A"))
   (0.05 -> (withdraw "I"))))

;; A chooses to proceed with the investment.
;; The funds are locked up to a certain time,
;; then she can withdraw the whole balance
(define (Invest)
  (split
   (1 -> (withdraw "I"))
   (0 -> (after 160000000 (put (x) (withdraw "A"))))))

;; A failed to choose whether to invest or retract.
;; SHe gets back her deposit minus a penalty.
;; I gets gets the penalty from A.
(define (Default)
  (split
   (0.9 -> (withdraw "A"))
   (0.1 -> (withdraw "I"))))
;--------------------------------------------------------------

(contract
 (pre (deposit "A" 1 (ref (txA)))
      (vol-deposit "I" x 1.1 (ref (txI)))

      (fee "A" 0.01 (ref (txFee))))
 
 (ref (AmericanOption "A" 1550000 Retract Invest Default))
 
 (check-liquid))