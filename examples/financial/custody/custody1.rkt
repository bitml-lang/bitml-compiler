#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")
(participant "C" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(participant "S" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f829")

(debug-mode)

(contract
 (pre (deposit "A" 1 "txid:something@0"))
 
 (choice
  (auth "A" "B" (withdraw "S"))
  (auth "A" "C" (withdraw "S"))
  (auth "B" "C" (withdraw "S")))
 
 (check-liquid
  (strategy "A" (do-auth))
  (strategy "B" (do-auth)))
 )