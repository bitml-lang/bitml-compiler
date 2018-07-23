#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")

(key "A" (auth "A" (after 30 (after 20 (withdraw "B")))) "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(key "B" (auth "A" (after 30 (after 20 (withdraw "B")))) "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")

(advertise (guards (deposit "A" 1 "txA@0")
                   (deposit "A" 1 "txA1@0")
                   (deposit "B" 2 "txB@0"))
           (auth "A" (after 30 (after 20 (withdraw "B")))))