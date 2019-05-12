#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(contract
 (pre 
  (deposit "A" 1 "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
  (deposit "B" 1 "txid:0f795bda36ac661f2b9a626d46049bc14b95b2d0e69f5fb7ccc4c3d767db9f34@1")
  (secret "A" a "f9292914bfd27c426a23465fc122322abbdb63b7")
  (secret "B" b "9804ebb0fc4a8329981dd33aaff32b6cb579580a"))
		 
 (split
  (1 -> (reveal (a) (withdraw "A")))
  (1 -> (reveal (b) (withdraw "B"))))

 (check "A" has-at-least 1
        (strategy "A" (do-reveal a))))