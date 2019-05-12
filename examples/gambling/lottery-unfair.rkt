#lang bitml

(debug-mode)

(auto-generate-secrets)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(contract (pre
          (deposit "A" 3 "txA@0")(secret "A" a "14f06dde2fa12bd359ea0847de296f7b66a0f93f")
          (deposit "B" 3 "txB@0")(secret "B" b "18ed15665ab53ba8f4c965748e8a657cf40ee3f2"))
         
         (split
          (2 -> (choice
                 (reveal (b) (withdraw "B"))
                 (after 10 (withdraw "A"))))
          (2 -> (choice
                 (reveal (a) (withdraw "A"))
                 (after 10 (withdraw "B"))))
          (2 -> (choice
                 (revealif (a b) (pred (= a b)) (withdraw "A"))
                 (revealif (a b) (pred (!= a b)) (withdraw "B")))))

         (check-liquid))