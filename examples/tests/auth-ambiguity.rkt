#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(generate-keys)

(contract
 (pre 
  (deposit "A" 1 "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
  (secret "A" a "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb")
  (secret "A" a1 "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"))
	 
 (sum
  (reveal (a) (auth "B" (withdraw "A")))
  (reveal (a1) (auth "B" (withdraw "A"))))

 (check-liquid
  (strategy "A" (do-reveal a))
  (strategy "B" (do-auth (auth "B" (withdraw "A"))))))

#|
The authorization for (auth "B" (withdraw "A"))
unlocks both branches of the sum, so it is "context independent".

To disambiguate, create an alias for the same participant with the same pubkey,
as follows
|#

(participant "B1" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(contract
 (pre 
  (deposit "A" 1 "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
  (secret "A" a "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb")
  (secret "A" a1 "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"))
	 
 (sum
  (reveal (a) (auth "B1" (withdraw "A")))
  (reveal (a1) (auth "B" (withdraw "A"))))

 (check-liquid
  (strategy "A" (do-reveal a))
  (strategy "B" (do-auth (auth "B" (withdraw "A"))))))