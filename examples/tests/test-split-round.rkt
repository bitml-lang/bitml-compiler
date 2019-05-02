#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(define (txA) "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")

(contract
 (pre (deposit "A" 1 (ref (txA))) (secret "A" a "aaa"))
 
 (split
  (0.1 -> (revealif (a) (pred (= a 1)) (withdraw "A")))
  (0.1 -> (revealif (a) (pred (= a 2)) (withdraw "A")))
  (0.1 -> (revealif (a) (pred (= a 3)) (withdraw "A")))
  (0.1 -> (revealif (a) (pred (= a 4)) (withdraw "A")))
  (0.1 -> (revealif (a) (pred (= a 5)) (withdraw "A")))
  (0.1 -> (revealif (a) (pred (= a 6)) (withdraw "A")))
  (0.1 -> (revealif (a) (pred (= a 7)) (withdraw "A")))
  (0.1 -> (revealif (a) (pred (= a 8)) (withdraw "A")))
  (0.1 -> (revealif (a) (pred (= a 9)) (withdraw "A")))
  (0.1 -> (revealif (a) (pred (!= a 1)) (withdraw "A"))))

 (check-liquid (strategy "A" (do-reveal a))))
