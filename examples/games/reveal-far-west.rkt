#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(define txA "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
(define txB "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@2")

(contract
 (pre (deposit "A" 1 (ref txA)) (secret "A" a "a-Hash")
      (deposit "B" 1 (ref txB)) (secret "B" b "b-Hash"))
 
 (choice
  (reveal (a) (withdraw "A"))
  (reveal (b) (choice
    (reveal (a) (withdraw "B"))
    (after 200 (withdraw "A"))))
  (after 100
   (split
    (0.5 -> (withdraw "A"))
    (1.5 -> (withdraw "B")))))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; A honest participant

  ; First, we observe that unless A follows some specific strategy, B can
  ; always make her lose all the deposit
 
  ; if B reveals after A, A does not always win something
  (check-query "<> (A has-deposit>= 1 satoshi)"
    ; no strategy for "A"
    (strategy "B" (do-reveal b) if ("A" (do-reveal a)))) ; result: false

  ; Second, if A chooses to reveal, she loses
  
  ; if both reveal, A does not obtain anything, in the worst case
  (check-query "<> (A has-deposit>= 1 satoshi)"
    (strategy "A" (do-reveal a))
    (strategy "B" (do-reveal b))) ; result: false

  ; Even if A chooses to reveal only after B, she loses anyway
  
  (check-query "<> (A has-deposit>= 1 satoshi)"
    (strategy "A" (do-reveal a) if ("B" (do-reveal b)))
    (strategy "B" (do-reveal b))
    ) ; result: false
  
  ; Third, if A does not reveal, she wins half of her deposit
  
  ; if A does not reveal, A wins at least 0.5 BTC
  (check-query "<> (A has-deposit>= 50000000 satoshi)"
    (strategy "A" (not-reveal a))) ; result: true
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; B honest participant

  ; Here B never wins anything, in the worst case, since if A is the
  ; adversary, A can reveal and withdraw 2 BTC before B does any move.
  ; No matter what strategy B uses, he can not win anything.
  
  ; in the worst case, B does not win
  (check-query "<> (B has-deposit>= 1 satoshi)"
    (strategy "B" (do-reveal b) if ("A" (do-reveal a)))) ; result: false

  ; in the worst case, B does not win
  (check-query "<> (B has-deposit>= 1 satoshi)"
    (strategy "B" (not-reveal b))
    ) ; result: false


)