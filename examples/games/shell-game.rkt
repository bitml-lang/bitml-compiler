#lang bitml

(debug-mode)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced") ; player
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30") ; dealer

(define Bet0
  (sum
   (auth "B" (withdraw "A"))     ; B says that A wins
   (auth "B" (tau (ref Check0))) ; B says that A loses (check)
   (after 10 (withdraw "A"))))   ; B is late

(define Bet1
  (sum
   (auth "B" (withdraw "A"))     ; B says that A wins
   (auth "B" (tau (ref Check1))) ; B says that A loses (check)
   (after 10 (withdraw "A"))))   ; B is late

(define Bet2
  (sum
   (auth "B" (withdraw "A"))     ; B says that A wins
   (auth "B" (tau (ref Check2))) ; B says that A loses (check)
   (after 10 (withdraw "A"))))   ; B is late

(define Check0
  (sum
   (revealif (b) (pred (and (!= b 0) (between b 0 2))) (withdraw "B"))
   (after 10 (withdraw "A"))))

(define Check1
  (sum
   (revealif (b) (pred (and (!= b 1) (between b 0 2))) (withdraw "B"))
   (after 10 (withdraw "A"))))

(define Check2
  (sum
   (revealif (b) (pred (and (!= b 2) (between b 0 2))) (withdraw "B"))
   (after 10 (withdraw "A"))))

(contract (pre
             (deposit "A" 1 "txA@0")
             (deposit "B" 1 "txB@0")
             (secret "B" b "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35"))
          (sum
           (auth "A" (tau (ref Bet0))) ; A chooses 0
           (auth "A" (tau (ref Bet1))) ; A chooses 1
           (auth "A" (tau (ref Bet2))) ; A chooses 2
           (after 10 (withdraw "B"))   ; A is late
           )

          (check-query "[] (b revealed-size 3 => <> A has-deposit>= 200000000 satoshi)"))