#lang bitml

(debug-mode)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "C" "03e969a9e8080b7515d4bbeaf253978b33226dd3c4fbc987d9b67fb2e5380cca9f")
(participant "D" "033ed7a4e8386a38333d6b7db03f532edece48ef3160688d73091644ecf0754910")

(define (Round1AB)
  (choice
   (revealif (b1) (pred (between b1 0 1))
             (choice
              (revealif (a1 b1) (pred (= a1 b1)) (ref (Round1CD "A" a2)))
              (revealif (a1 b1) (pred (!= a1 b1)) (ref (Round1CD "B" b2)))
              (after 10 (tau (ref (Round1CD "B" b2))))))
   (after 10 (tau (ref (Round1CD "A" a2))))))

(define (Round1CD P x)
  (choice
   (revealif (c1) (pred (between c1 0 1))
             (choice
              (revealif (c1 d1) (pred (= c1 d1)) (ref (Round2 P x "C" c2)))
              (revealif (c1 d1) (pred (!= c1 d1)) (ref (Round2 P x "D" d2)))
              (after 10 (tau (ref (Round2 P x "C" c2))))))
   (after 10 (tau (ref (Round2 P x "D" d2))))))

(define (Round2 P1 x1 P2 x2)
  (choice
   (revealif (x1) (pred (between x1 0 1))
             (choice
              (revealif (x1 x2) (pred (= x1 x2)) (withdraw P1))
              (revealif (x1 x2) (pred (!= x1 x2)) (withdraw P2))
              (after 10 (withdraw P1))))
   (after 10 (withdraw P2)))
  )

(contract (pre
           (deposit "A" 7 "txA@0")(deposit "B" 7 "txB@0")(deposit "C" 7 "txC@0")(deposit "D" 7 "txD@0")
           (secret "A" a1 "c51b66bced5e4491001bd702669770dccf440982") (secret "A" a2 "f9292914bfd27c426a23465fc122322abbdb63b7")
           (secret "B" b1 "9804ebb0fc4a8329981dd33aaff32b6cb579580a") (secret "B" b2 "18ed15665ab53ba8f4c965748e8a657cf40ee3f2")
           (secret "C" c1 "183c86e0a286ac99ad8cf5c4cde36511181ffbd5") (secret "C" c2 "ded836a730cdeca5223f2609747074585f933aa8")
           (secret "D" d1 "14f06dde2fa12bd359ea0847de296f7b66a0f93f") (secret "D" d2 "7249ab836ec75abf7756aec7528812a86a9f23df"))

          (ref (Round1AB))
                   

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