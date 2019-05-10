#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(auto-generate-secrets)

(define (txA) "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
(define (txB) "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@2")

(define (B x not-x) ;x is the guess of B
  (auth "B" (tau
   (choice
    (revealif (a) (pred (= a x)) (withdraw "B"))
    (revealif (a) (pred (= a not-x)) (withdraw "A"))
    (after 2000 (withdraw "A"))))))

(contract
 (pre (deposit "A" 1 (ref (txA))) (secret "A" a "a-Hash")
      (deposit "B" 1 (ref (txB))))
 
 (choice
  ; B guesses "0"
  (ref (B 0 1))
  ; B guesses "1"
  (ref (B 1 0))
  (after 1000 (withdraw "A")))
  
 (check-liquid (strategy "B" (do-auth (ref (B 0 1)))))

 (check-liquid)
 )