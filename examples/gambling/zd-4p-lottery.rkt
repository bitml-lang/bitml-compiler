#lang bitml

(debug-mode)

;(auto-generate-secrets)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "C" "03e969a9e8080b7515d4bbeaf253978b33226dd3c4fbc987d9b67fb2e5380cca9f")
(participant "D" "033ed7a4e8386a38333d6b7db03f532edece48ef3160688d73091644ecf0754910")

(define (Round1A)
  (choice
   (revealif (b1) (pred (= b1 0)) (ref (Round1AB 0)))
   (after 10 (tau (choice
                   (revealif (b1) (pred (= b1 1)) (ref (Round1AB 1)))
                   (after 10 (tau (ref (Round1C "A" a2)))))))
   ))

(define (Round1AB x)
  (choice
   (revealif (b1) (pred (= b1 x)) (ref (Round1C "A" a2)))
   (after 10 (tau (choice
                   (revealif (b1) (pred (!= b1 x)) (ref (Round1C "B" b2)))
                   (after 10 (tau (ref (Round1C "B" b2)))))))
   ))

(define (Round1C P x)
  (choice
   (revealif (c1) (pred (= c1 0)) (ref (Round1CD P x 0)))
   (after 10 (tau (choice
                   (revealif (c1) (pred (= c1 1)) (ref (Round1CD P x 1)))
                   (after 10 (tau (ref (Round2 P x "D" d2)))))))
   ))

(define (Round1CD P y x)
  (choice
   (revealif (d1) (pred (= d1 x)) (ref (Round2 P y "C" c2)))
   (after 10 (tau (choice
                   (revealif (d1) (pred (!= d1 x)) (ref (Round2 P y "D" d2)))
                   (after 10 (tau (ref (Round2 P y "C" c2)))))))
   ))

(define (Round2 P1 x1 P2 x2)
  (choice
   (revealif (x1) (pred (= x1 1)) (ref (FinalRound 1 P1 x1 P2 x2)))
   (after 10 (tau (choice
                   (revealif (x1) (pred (= x1 0)) (ref (FinalRound 0 P1 x1 P2 x2)))
                   (after 10 (withdraw P2)))))
   ))

(define (FinalRound y P1 x1 P2 x2)
  (choice
   (revealif (x2) (pred (= x2 y)) (withdraw P2))
   (after 10 (withdraw P1))))

(contract (pre
           (deposit "A" 7 "txA@0")(deposit "B" 7 "txB@0")(deposit "C" 7 "txC@0")(deposit "D" 7 "txD@0")
           (secret "A" a1 "c51b66bced5e4491001bd702669770dccf440982") (secret "A" a2 "f9292914bfd27c426a23465fc122322abbdb63b7")
           (secret "B" b1 "9804ebb0fc4a8329981dd33aaff32b6cb579580a") (secret "B" b2 "18ed15665ab53ba8f4c965748e8a657cf40ee3f2")
           (secret "C" c1 "183c86e0a286ac99ad8cf5c4cde36511181ffbd5") (secret "C" c2 "ded836a730cdeca5223f2609747074585f933aa8")
           (secret "D" d1 "14f06dde2fa12bd359ea0847de296f7b66a0f93f") (secret "D" d2 "7249ab836ec75abf7756aec7528812a86a9f23df"))

          (ref (Round1A))
                   

          ;(check-liquid
          ; (strategy "A" (do-reveal a1))
          ; (strategy "A" (do-reveal a2))
          ; (strategy "B" (do-reveal b1))
          ; (strategy "B" (do-reveal b2))
          ; (strategy "C" (do-reveal c1))
          ; (strategy "C" (do-reveal c2))
          ; (strategy "D" (do-reveal d1))
          ; (strategy "D" (do-reveal d2)))

          )