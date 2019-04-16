#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(generate-keys)

(contract
 (pre 
  (deposit "A" 1 "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
  (deposit "B" 1 "txid:0f795bda36ac661f2b9a626d46049bc14b95b2d0e69f5fb7ccc4c3d767db9f34@1")
  (secret "A" a "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb")
  (secret "B" b "3e23e8160039594a33894f6564e1b1348bbd7a0088d42c4acb73eeaed59c009d"))
		 
 (split
  (1 -> (reveal (a) (withdraw "A")))
  (1 -> (reveal (b) (withdraw "B"))))

 (check "A" has-more-than 1
        (strategy "A" (do-reveal a))))