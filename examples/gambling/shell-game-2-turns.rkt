#lang bitml

(debug-mode)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced") ; player
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30") ; dealer

(define (Bet n)
  (choice
   (auth "B" (withdraw "A"))     ; B says that A wins
   (auth "B" (put (w) (ref (Lose n)))) ; B says that A loses
   (after 10 (withdraw "A"))))   ; B is late

(define (Lose n)
  (choice
   (auth "A" (put (y) (ref (Bet2 n 0))))
   (auth "A" (put (y) (ref (Bet2 n 1))))
   (auth "A" (put (y) (ref (Bet2 n 2))))
   (auth "A" (tau (ref (Check n))))
   (after 20 (withdraw "B"))))

(define (Check n)
  (choice
   (revealif (b) (pred (and (!= b n) (between b 0 2))) (withdraw "B"))
   (after 10 (withdraw "A"))))

(define (Bet2 n m)
  (choice
   (revealif (b) (pred (and (!= b n) (and (!= b m) (between b 0 2)))) (withdraw "B"))
   (after 20 (withdraw "A"))))

(contract (pre
           (deposit "A" 1 "txA@0")
           (vol-deposit "A" y 1 "txA@1")
           (deposit "B" 1 "txB@0")
           (vol-deposit "B" w 1 "txB@1")
           (secret "B" b "de81500d472e6356185374ac8dc9a60b528b4a67"))
          
          (choice
           (auth "A" (tau (ref (Bet 0)))) ; A chooses 0
           (auth "A" (tau (ref (Bet 1)))) ; A chooses 1
           (auth "A" (tau (ref (Bet 2)))) ; A chooses 2
           (after 10 (withdraw "B"))   ; A is late
           )

          (check-query "[] (b revealed-size 3 => <> A has-deposit>= 200000000 satoshi)"))