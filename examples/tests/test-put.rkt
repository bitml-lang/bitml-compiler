#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(contract
 (pre 
  (deposit "A" 1 "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
  (vol-deposit "B" txb 1 "txVA@2") (vol-deposit "B" txb2 1 "txVB@2"))
	 
 (put (txb txb2) (withdraw "A"))

 (check-liquid
  (strategy "B" (not-destroy txb))))