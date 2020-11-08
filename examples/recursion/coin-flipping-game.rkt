#lang bitml

(participant "A" "keyA")
(participant "B" "keyB")

(define (txA) "tx:txA@0")
(define (txB) "tx:txB@0")

(define (SplitA)
  (split (4 -> (withdraw "A")) (2 -> (withdraw "B"))))

(define (SplitB)
  (split (2 -> (withdraw "A")) (4 -> (withdraw "B"))))


(debug-mode)

(contract
 (pre (deposit "A" 3 (ref (txA)))
      (deposit "B" 3 (ref (txB)))
      (secret "A" a "a_hash")
      (secret "B" b "b_hash"))

 
 (choice
  (revealif (b) (pred (between b 0 1))
            (choice
             (revealif (a b) (pred (= a b))  (choice (rngt "Xa") (after 3 (ref (SplitA)))))
             (revealif (a b) (pred (!= a b)) (choice (rngt "Xb") (after 3 (ref (SplitB)))))
             (after 2 (withdraw "B"))))
  (after 1 (withdraw "A")))
         

 (define-rec "Xa"
   (choice
    (revealif (b) (pred (between b 0 1))
              (choice
               (revealif (a b) (pred (= a b))  (withdraw "A"))
               (revealif (a b) (pred (!= a b)) (choice (rngt "Xb") (after 3 (ref (SplitB)))))
               (after 2 (withdraw "B"))))
    (after 1 (withdraw "A"))))

 (define-rec "Xb"
   (choice
    (revealif (b) (pred (between b 0 1))
              (choice
               (revealif (a b) (pred (= a b))  (choice (rngt "Xa") (after 3 (ref (SplitA)))))
               (revealif (a b) (pred (!= a b)) (withdraw "B"))
               (after 2 (withdraw "B"))))
    (after 1 (withdraw "A"))))


 (check-liquid)

 )

