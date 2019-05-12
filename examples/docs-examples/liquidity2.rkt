#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")


(debug-mode)

(contract
 (pre 
  (deposit "A" 1 "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
  (secret "A" a "9804ebb0fc4a8329981dd33aaff32b6cb579580a"))
	 
 (choice
  (reveal (a) (withdraw "A"))
  (auth "B" (after 700000  (withdraw "B"))))
 
 (check-liquid
  (strategy "A" (do-reveal a)))
 
 (check-liquid
  (strategy "B" (do-auth)))

 (check-liquid
  (strategy "A" (do-reveal a) if
            ("B" (do-auth (auth "B" (after 700000 (withdraw "B"))))))))