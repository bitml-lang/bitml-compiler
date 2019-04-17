#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")
(participant "C" "034f5ca30056b9dd89132ca8c7583e6d82b69bc17bb2c1dfef9dea9c3467631e6b")
(participant "D" "037b60c121050e1fa6e7d5cd299ecc66d87330b2996567004f831c63ef0e2a157e")

(debug-mode)

(contract
 (pre 
  (deposit "A" 1 "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1")
  (deposit "A" 1 "txid:625bc69c467b33e2ad70ea2817874067604eb42dd5835403f54fb6028bc70168@0"))
	 
 (sum
  (auth "A" "B" (withdraw "C"))
  (auth "A" "B" (withdraw "D"))
  (after 700000 (split (1 -> (withdraw "A")) (1 -> (withdraw "B")))))

 (check-liquid))