#lang bitml

(debug-mode)

;(auto-generate-secrets)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "C" "03e969a9e8080b7515d4bbeaf253978b33226dd3c4fbc987d9b67fb2e5380cca9f")
(participant "D" "033ed7a4e8386a38333d6b7db03f532edece48ef3160688d73091644ecf0754910")

; C = committer, x = secret, Ai = other players
(define (TC C x A1 A2 A3)
  (choice
   (revealif (x) (pred (between x 0 1)) (withdraw C))
   (after 10 (split (1 -> (withdraw A1)) (1 -> (withdraw A2)) (1 -> (withdraw A3)))))
  )

(define (Round1)
  (choice
   (revealif (a1 b1) (pred (= a1 b1))
             (choice
              (revealif (c1 d1) (pred (= c1 d1)) (ref (Round2 "A" a2 "C" c2)))
              (revealif (c1 d1) (pred (!= c1 b1)) (ref (Round2 "A" a2 "D" d2)))))
   (revealif (a1 b1) (pred (!= a1 b1))
             (choice
              (revealif (c1 d1) (pred (= c1 d1)) (ref (Round2 "B" b2 "C" c2)))
              (revealif (c1 d1) (pred (!= c1 b1)) (ref (Round2 "B" b2 "D" d2)))))))

(define (Round2 P1 x1 P2 x2)
  (choice
   (revealif (x1 x2) (pred (= x1 x2)) (withdraw P1))
   (revealif (x1 x2) (pred (!= x1 x2)) (withdraw P2)))
  )

(contract (pre
           (deposit "A" 7 "txA@0")(deposit "B" 7 "txB@0")(deposit "C" 7 "txC@0")(deposit "D" 7 "txD@0")
           (secret "A" a1 "f55ff16f66f43360266b95db6f8fec01d76031054306ae4a4b380598f6cfd114") (secret "A" a2 "2c3a4249d77070058649dbd822dcaf7957586fce428cfb2ca88b94741eda8b07")
           (secret "B" b1 "7dc96f776c8423e57a2785489a3f9c43fb6e756876d6ad9a9cac4aa4e72ec193") (secret "B" b2 "4814d92093ac8a0f4a2163ab87dee509ba306a58f5888be0edcb2fcd0712028b")
           (secret "C" c1 "d0f631ca1ddba8db3bcfcb9e057cdc98d0379f1bee00e75a545147a27dadd982") (secret "C" c2 "9c0abe51c6e6655d81de2d044d4fb194931f058c0426c67c7285d8f5657ed64a")
           (secret "D" d1 "8b53639f152c8fc6ef30802fde462ba0be9cf085f7580dc69efd72e002abbb35") (secret "D" d2 "e788103ee15318fcd2af9b73b4ebbb33a903b020de7b307d71f5fed0f433e548"))
         
          (split
           (3 -> (ref (TC "A" a1 "B" "C" "D")))
           (3 -> (ref (TC "A" a2 "B" "C" "D")))
           (3 -> (ref (TC "B" b1 "A" "C" "D")))
           (3 -> (ref (TC "B" b2 "A" "C" "D")))
           (3 -> (ref (TC "C" c1 "A" "B" "D")))
           (3 -> (ref (TC "C" c2 "A" "B" "D")))
           (3 -> (ref (TC "D" d1 "A" "B" "C")))
           (3 -> (ref (TC "D" d2 "A" "B" "C")))
           
           (4 -> (ref (Round1))))

          #;(check-liquid))