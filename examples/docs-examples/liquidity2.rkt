#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")
(participant "B1" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")


(generate-keys)

(contract
 (pre 
  (deposit "A" 1 "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
  (secret "A" a "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"))
	 
 (sum
  (reveal (a) (withdraw "A"))
  (auth "B1" (auth "B" (withdraw "B"))))

 (check-liquid
  (strategy "A" (do-reveal a)))
 
 (check-liquid
  (strategy "B" (do-auth (auth (withdraw "B"))))
  (strategy "B1" (do-auth (auth "BGATTI" "B1" (withdraw "B"))))))