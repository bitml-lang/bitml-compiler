#lang bitml

(debug-mode)
(verification-only)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "S" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30") ; seller

; auction with 2 rounds
; possible bets 1, 2
; 2 is the "buy me now" price

; hB = highest bidder, lB = lowest bidder

(define (RunningAuction1 hB lB)
  (tau (choice
        (auth "A" (ref (WonAuction2 "A" "B")))        ; A wins!
        (auth "B" (ref (WonAuction2 "B" "A")))        ; B wins!
        (auth lB (ref (WonAuction1 hB lB)))           ; lB forfeits
        (after 20 (ref (WonAuction1 hB lB)))          ; hB wins - timeout
        ))
  )

(define (WonAuction1 hB lB)
  (tau (split (1 -> (withdraw "S")) (1 -> (withdraw hB)) (2 -> (withdraw lB)))))

(define (WonAuction2 hB lB)
  (tau (split (2 -> (withdraw "S")) (2 -> (withdraw lB)))))


(contract (pre
           (deposit "A" 2 "txA@0")
           (deposit "B" 2 "txB@0"))
          (choice
           (auth "A" (ref (RunningAuction1 "A" "B")))  ; A bids first
           (auth "B" (ref (RunningAuction1 "B" "A")))  ; B bids first
           (after 10 (split (2 -> (withdraw "A")) (2 -> (withdraw "B"))))
           )

          (check-liquid)
          )