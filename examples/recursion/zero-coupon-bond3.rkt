#lang bitml

(participant "A" "keyA")
(participant "B" "keyB")
(participant "I" "keyI")

(debug-mode)

(contract
 (pre (deposit "A" 1 "tx:txA@0")
      (deposit "I" 3 "tx:txB@0")
      (deposit "B" 0.3 "tx:txI@0"))

 
 (split
  (1 -> (withdraw "B"))
  (0.3 -> (withdraw "I"))
  (3 -> (choice
         (rngt "X1")
         (after 2021 (withdraw "A"))))) 

 (define-rec "X1"
   (pre (deposit "B" 0.3 ""))
   (split
    (0.3 -> (withdraw "I"))
    (3 -> (choice
           (rngt "X2")
           (after 2022 (withdraw "A"))))))

 (define-rec "X2"
   (pre (deposit "B" 0.3 ""))
   (split
    (0.3 -> (withdraw "I"))
    (3 -> (choice
           (rngt "X3")
           (after 2023 (withdraw "A"))))))

 (define-rec "X3"
   (pre (deposit "B" 0.3 ""))
   (split
    (0.3 -> (withdraw "I"))
    (3 -> (choice
           (rngt "X4")
           (after 2024 (withdraw "A"))))))

 (define-rec "X4"
   (pre (deposit "B" 0.3 ""))
   (split
    (0.3 -> (withdraw "I"))
    (3 -> (choice
           (rngt "X5")
           (after 2025 (withdraw "A"))))))

 (define-rec "X5"
   (pre (deposit "B" 0.3 ""))
   (split
    (0.3 -> (withdraw "I"))
    (3 -> (choice
           (rngt "X6")
           (after 2026 (withdraw "A"))))))

 (define-rec "X6"
   (pre (deposit "B" 0.3 ""))
   (split
    (0.3 -> (withdraw "I"))
    (3 -> (choice
           (rngt "X7")
           (after 2027 (withdraw "A"))))))

 (define-rec "X7"
   (pre (deposit "B" 0.3 ""))
   (split
    (0.3 -> (withdraw "I"))
    (3 -> (choice
           (rngt "X8")
           (after 2028 (withdraw "A"))))))

 (define-rec "X8"
   (pre (deposit "B" 0.3 ""))
   (split
    (0.3 -> (withdraw "I"))
    (3 -> (choice
           (rngt "X9")
           (after 2029 (withdraw "A"))))))

 (define-rec "X9"
   (pre (deposit "B" 0.3 ""))
   (split
    (0.3 -> (withdraw "I"))
    (3 -> (choice
           (rngt "X10")
           (after 2030 (withdraw "A"))))))        

 (define-rec "X10"
   (pre (deposit "B" 2 ""))
   (split
    (3 -> (withdraw "I"))
    (2 -> (after 2031 (withdraw "A"))))) 


 (check-liquid)

 )

