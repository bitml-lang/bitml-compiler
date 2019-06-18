#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")
(participant "C" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(participant "A1" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B1" "021927aa11df2776adc8fde8f36c4f7116dbfb466d6c2cd500ae3eabc0fcfb0a33")
(participant "C1" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(participant "Cur" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f819")
(participant "S" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f829")
(participant "T" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f229")


(debug-mode)

(define (Round1)
  (split 
   (0.1 -> (withdraw "Cur"))
   (0.9 -> (choice
            (auth "Cur" (ref (Round2)))
            (after 10 (withdraw "S"))))))

(define (Round2)
  (tau (choice
        (auth "A" "B" (ref (Veto)))
        (auth "A" "C" (ref (Veto)))
        (auth "B" "C" (ref (Veto))))))

(define (Veto)
  (tau (choice
        (auth "Cur" (withdraw "T"))
        (after 20 (withdraw "S")))))

(contract
 (pre (deposit "A" 1 "txid:something@0"))
 
 (choice
  (auth "A" "B" (ref (Round1)))
  (auth "A" "C" (ref (Round1)))
  (auth "B" "C" (ref (Round1))))
 
 )