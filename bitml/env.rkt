#lang racket/base

(require racket/list)

;ENVIRONMENT

(define output "")

(define (add-output str [pre #f])
  (if pre
      (set! output (string-append str "\n" output))
      (set! output (string-append output "\n" str))))

;generate keys for debug purposes
(define gen-keys #f)

(define (set-gen-keys!)
  (set! gen-keys #t))

(define (gen-keys?) gen-keys)

;security parameter (minimun secret length)
(define sec-param 128)

;function to enumerate tx indexes
(define tx-index 0)

(define (new-tx-index)
  (set! tx-index (add1 tx-index))
  tx-index)

(define (new-tx-name)
  (format "T~a" (new-tx-index)))

;helpers to store and retrieve participants' public keys
(define participants-table
  (make-hash))

(define (add-participant id pk)
  (hash-set! participants-table id pk))

(define (participant-pk id)
  (hash-ref participants-table id))

(define (get-participants)
  (hash-keys participants-table))

;helpers to store and retrieve participants' public keys for terms
(define pk-terms-table
  (make-hash))

(define (add-pk-for-term id term pk)
  (let ([name (format "pubkey~a~a" id (new-key-index))])
    (hash-set! pk-terms-table (cons id term) (list pk name))))

(define (pk-for-term id term)
  (hash-ref pk-terms-table (cons id term)
            (lambda ()
              (if gen-keys
                  (begin 
                    (add-pk-for-term id term "0277dc31c59a49ccdad15969ef154674b390e0028b50bdc1fa9b8de98be1320652")
                    (pk-for-term id term))
                  (raise (error 'bitml "no public key defined for participant ~a and contract ~a" id term))))))

(define key-index 0)

(define (new-key-index)
  (set! key-index (add1 key-index))
  key-index)

;helpers to store permanent deposits
(define parts empty)
(define (add-part id)
  (set! parts (cons id parts)))

(define deposit-txout empty)
(define (add-deposit txout)
  (set! deposit-txout (cons txout deposit-txout)))

(define tx-v 0)
(define (add-tx-v v)
  (set! tx-v (+ v tx-v)))

;helpers to store volatile deposits
(define volatile-deps-table
  (make-hash))

(define (add-volatile-dep part id val tx)
  (hash-set! volatile-deps-table id (list part val tx)))

(define (get-volatile-dep id)
  (hash-ref volatile-deps-table id))

;helpers to store the secrets
(define secrets-table
  (make-hash))

(define (add-secret part id hash)
  (hash-set! secrets-table id (list part hash)))

(define (get-secret-hash id)
  (second (hash-ref secrets-table id)))

(define (get-secret-part id)
  (first (hash-ref secrets-table id)))

(define (get-secrets)
  (hash-keys secrets-table))

;clear the state
(define (reset-state)
  (set! tx-v 0)
  (set! secrets-table (make-hash))
  (set! volatile-deps-table (make-hash))
  (set! deposit-txout empty)
  (set! parts empty)
  (set! tx-index 0))

(provide (all-defined-out))