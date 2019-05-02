#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(define (txA) "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")

(contract
 (pre (deposit "A" 5 (ref (txA))) (secret "A" a1 "aaa1") (secret "A" a2 "aaa2") (secret "A" a3 "aaa3") (secret "A" a5 "aaa5"))
 
 (split
  (1 -> (revealif (a1) (pred (= a1 1)) (withdraw "A")))
  ; (1 -> (revealif (a2) (pred (= a2 2)) (withdraw "A")))
  ; (1 -> (revealif (a3) (pred (= a3 3)) (withdraw "A")))
  ; (1 -> (revealif (a4) (pred (= a4 4)) (withdraw "A")))
  (4 -> (revealif (a5) (pred (= a5 5)) (withdraw "A")))
  )

 (check-liquid (strategy "A" (do-reveal a1))))
  ;(strategy "A" (do-reveal a2))))
