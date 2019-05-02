#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(define (txA) "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")

(define (C)
  (choice
   (auth "A" (withdraw "A"))
   (auth "B" (withdraw "B"))
   (reveal (a) (ref (C1)))
   (after 100 (withdraw "B"))))

(define (C1)
  (choice
   (auth "A" (withdraw "A"))
   (put (x) (withdraw "B"))
   (revealif (a) (pred (= a 1)) (withdraw "A"))
   (after 100 (withdraw "B"))))

(contract
 (pre (deposit "A" 5 (ref (txA))) (secret "A" a "ha") (secret "B" b "hb") (vol-deposit "A" x 1 "t1@0"))
 
 (choice
  (after 10 (tau (ref (C))))
  (after 20 (tau (ref (C))))
  (after 30 (tau (ref (C))))
  (after 40 (tau (ref (C))))
  (after 50 (tau (withdraw "A"))))

 (check-liquid)
 (check-query "[] (a revealed-size 1 => <> A has-deposit>= 200000000 satoshi)"))
