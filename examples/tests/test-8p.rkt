#lang bitml

;;; This examples shows that the tecnique used to save space in the 4 players lottery
;;; is not enough for the 8 players lottery, due to the high number of public keys

(debug-mode)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "C" "03e969a9e8080b7515d4bbeaf253978b33226dd3c4fbc987d9b67fb2e5380cca9f")
(participant "D" "033ed7a4e8386a38333d6b7db03f532edece48ef3160688d73091644ecf0754910")

(participant "E" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "F" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af31")
(participant "G" "03e969a9e8080b7515d4bbeaf253978b33226dd3c4fbc987d9b67fb2e5380cca9d")
(participant "H" "033ed7a4e8386a38333d6b7db03f532edece48ef3160688d73091644ecf0754911")


(contract (pre
           (deposit "A" 7 "txA@0")(deposit "B" 7 "txB@0")(deposit "C" 7 "txC@0")(deposit "D" 7 "txD@0")
           (secret "A" a1 "c51b66bced5e4491001bd702669770dccf440982"))

          (choice
           (revealif (a1) (pred (= a1 0)) (withdraw "A"))
           (after 10 (tau (withdraw "A"))))

          )