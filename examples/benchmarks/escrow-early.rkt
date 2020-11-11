#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "M" "029e72227cb7a26eb45813c4a4ecb50894564bc9fe04ff4060f3b05f1ec5587738")

(debug-mode)
(verification-only)

(define (Resolve v w)
  (split
   (v -> (withdraw "M"))
   (w -> (choice (auth "M" (withdraw "A")) (auth "M" (withdraw "B"))))
   )
  )

(contract
 (pre (deposit "A" 1 "txA@0"))
 (choice
  (auth "A" (withdraw "B"))
  (auth "B" (withdraw "A"))
  (auth "A" (ref (Resolve 0.1 0.9)))
  (auth "B" (ref (Resolve 0.1 0.9)))
  )          
 
 (check-liquid)    
 )
