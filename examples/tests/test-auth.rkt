#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe0")
(participant "A1" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "A2" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe2")
(participant "A3" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe3")
(participant "A4" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe4")
(participant "A5" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe5")
(participant "A6" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe6")
(participant "A7" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe7")
(participant "A8" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe8")
(participant "A9" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe9")

(debug-mode)

(contract
 (pre 
  (deposit "A" 1 "txid:2e647d8566f00a08d276488db4f4e2d9f82dd82ef161c2078963d8deb2965e35@1"))
 
 (auth "A1" "A2" "A3" "A4" "A5" "A6" "A7" "A8" "A9" (withdraw "A"))
 )

;  (check-liquid
;   (strategy "A" (do-reveal a))
;  (strategy "B" (do-auth (auth "B" (withdraw "A")))))


