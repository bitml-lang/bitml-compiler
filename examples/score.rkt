#lang bitml

(participant "AP" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "AE" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "ACE" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "AV" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "ACV" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "AI" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")


(debug-mode)

(define Init (sum (auth "AE" (tau (ref Exec1)))
                  (after 10 (ref Canc))))

(define Exec1 (sum (auth "ACE" (tau (ref ApprE1)))
                   (auth "ACE" (tau (ref Exec2)))
                   (auth "ACE" (ref Canc))))

(define Exec2 (sum (auth "ACE" (tau (ref ApprE2)))
                   (auth "ACE" (ref Canc))))

(define ApprE1 (sum (auth "AV" (tau (ref Ver1)))
                    (auth "AV" (tau (ref Exec2)))
                    (auth "AV" (ref Canc))))

(define ApprE2 (sum (auth "AV" (tau (ref Ver1)))
                    (auth "AV" (ref Canc))))

(define Ver1 (sum (auth "ACV" (tau (ref ApprV)))
                  (auth "ACV" (tau (ref Ver2)))
                  (auth "ACV" (ref Canc))))

(define Ver2 (sum (auth "ACV" (tau (ref ApprV)))
                  (auth "ACV" (ref Canc))))

(define ApprV (sum (auth "AI" (ref Insp))
                   (auth "AI" (ref Canc))))

(define Insp (auth "AP" (ref Del)))

(define Del (auth "AP" (split (1 -> (withdraw "AE"))
                              (1 -> (withdraw "AV")))))

(define Canc (withdraw "AP"))

(contract
 (pre (deposit "AP" 2 "txA@0"))
 (ref Init)
 (check-liquid))