#lang bitml

(debug-mode)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "S" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30") ; seller

; auction with 3 rounds
; possible bets 1, 2, or 3
; 3 is the "buy me now" price

; hB = highest bidder, lB = lowest bidder

(define (RunningAuction1 hB lB)
  (tau (choice
        (auth hB (ref (RunningAuction2 hB lB)))  ; hB raises its bid
        (auth lB (ref (RunningAuction2 lB hB)))  ; lB outbids hB and becomes hB
        (auth "A" (ref (WonAuction3 "A" "B")))        ; A buys it now!
        (auth "B" (ref (WonAuction3 "B" "A")))        ; B buys it now!
        (auth lB (ref (WonAuction1 hB lB)))          ; lB forfeits
        (after 10 (ref (WonAuction1 hB lB)))         ; hB wins - timeout
        ))
  )

(define (RunningAuction2 hB lB)
  (tau (choice
        (auth "A" (ref (WonAuction3 "A" "B")))        ; A wins!
        (auth "B" (ref (WonAuction3 "B" "A")))        ; B wins!
        (auth lB (ref (WonAuction2 hB lB)))          ; lB forfeits
        (after 20 (ref (WonAuction2 hB lB)))         ; hB wins - timeout
        ))
  )

(define (WonAuction1 hB lB)
  (tau (split (1 -> (withdraw "S")) (2 -> (withdraw hB)) (3 -> (withdraw lB)))))

(define (WonAuction2 hB lB)
  (tau (split (2 -> (withdraw "S")) (1 -> (withdraw hB)) (3 -> (withdraw lB)))))

(define (WonAuction3 hB lB)
  (tau (split (3 -> (withdraw "S")) (3 -> (withdraw lB)))))


(contract (pre
           (deposit "A" 3 "txA@0")
           (deposit "B" 3 "txB@0"))
          (choice
           (auth "A" (ref (RunningAuction1 "A" "B")))  ; A bids first
           (auth "B" (ref (RunningAuction1 "B" "A")))  ; B bids first
           (after 10 (split (3 -> (withdraw "A")) (3 -> (withdraw "B"))))
           )

          (check-liquid)
          )