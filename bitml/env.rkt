#lang racket/base

(require racket/list racket/match)

;ENVIRONMENT

(define output "")

(define (add-output str [pre #f])
  (if pre
      (set! output (string-append str "\n" output))
      (set! output (string-append output "\n" str))))

;don't compile transactions (only verification)
(define hide-tx #f)

(define (set-hide-tx!)
  (set! hide-tx #t))

(define (hide-tx?) hide-tx)

;generate keys for debug purposes
(define gen-keys #f)

(define (set-gen-keys!)
  (set! gen-keys #t))

(define (gen-keys?) gen-keys)

;automatic generation of the secrets
(define generate-secrets #f)

(define (set-gen-secs!)
  (set! generate-secrets #t))

(define (gen-secs?) generate-secrets)

;security parameter (minimun secret length)
(define sec-param 128)

;fee per kb
(define fee-per-tx 0.0003)

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
  (if (hash-has-key? participants-table id)
      (raise-syntax-error 'bitml (format "Participant ~a already defined" id) #f)
      (hash-set! participants-table id pk)))

(define (participant-pk id)
  (hash-ref participants-table id
            (lambda ()
              (raise-syntax-error 'bitml (format "Participant ~a not defined" id) #f))))

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
                    (add-pk-for-term id term (participant-pk id))
                    (pk-for-term id term))
                  (raise-syntax-error 'bitml (format "No public key defined for participant ~a and contract ~a" id term) #f)))))

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
  (if (member txout deposit-txout)
      (raise-syntax-error 'bitml (format "Tx output ~a already locked by another deposit" txout) #f)
      (set! deposit-txout (cons txout deposit-txout))))

(define tx-v 0)
(define (add-tx-v v)
  (set! tx-v (+ v tx-v)))

;helpers to store volatile deposits
(define volatile-deps-table
  (make-hash))

(define (add-volatile-dep part id val tx)
  (let ([id? (hash-has-key? volatile-deps-table id)]
        [tx? (member tx (flatten (hash-values volatile-deps-table)))])
    (match (list id? tx?)
      [(list #t _)
       (raise-syntax-error 'bitml (format "Volatile deposit ~a already defined" id) #f)]
      [(list _ (list _))
       (raise-syntax-error 'bitml (format "tx output ~a already locked by another volatile deposit" tx) #f)]
      [(list #f #f)
       (hash-set! volatile-deps-table id (list part val tx))])))

(define (get-volatile-dep id)
  (hash-ref volatile-deps-table id
            (lambda ()
              (raise-syntax-error 'bitml (format "Volatile deposit ~a not defined" id) #f))))

(define (get-volatile-deps)
  (hash-keys volatile-deps-table))

;helpers to store the secrets
(define secrets-table
  (make-hash))

(define (add-secret part id hash)
  (let ([id? (hash-has-key? secrets-table id)]
        [hash? (member hash (flatten (hash-values secrets-table)))])
    (match (list id? hash?)
      [(list #t _)
       (raise-syntax-error 'bitml (format "Secret ~a already defined" id) #f)]
      [(list _ (list _))
       (raise-syntax-error 'bitml (format "Hash ~a already committed by another secret" hash) #f)]
      [(list #f #f)
       (hash-set! secrets-table id (list part hash))])))

(define (get-secret-hash id)
  (second
   (hash-ref secrets-table id
             (lambda ()
               (raise-syntax-error 'bitml (format "Secret ~a not defined" id) #f)))))

(define (get-secret-part id)
  (first
   (hash-ref secrets-table id
             (lambda ()
               (raise-syntax-error 'bitml (format "Secret ~a not defined" id) #f)))))

(define (get-secrets)
  (hash-keys secrets-table))

;helpers to store fee deposits
(define fee-deps-table
  (make-hash))

(define use-fee #f)

(define avail-fee 0)

(define (add-fee-dep part val tx)
  (let ([id? (hash-has-key? fee-deps-table part)]
        [tx? (member tx (flatten (hash-values fee-deps-table)))])
    (set! use-fee #t)
    (match (list id? tx?)
      [(list #t _)
       (raise-syntax-error 'bitml (format "Fee deposit for participant ~a already defined" part) #f)]
      [(list _ (list _))
       (raise-syntax-error 'bitml (format "tx output ~a already locked by another fee deposit" tx) #f)]
      [(list #f #f)
       (begin
         (set! avail-fee (+ avail-fee val))
         (hash-set! fee-deps-table part (list val tx)))])))

(define (get-fee-dep part)
  (hash-ref fee-deps-table part
            (lambda ()
              (raise-syntax-error 'bitml (format "Fee deposit for participant ~a not defined" part) #f))))

(define (get-fee-deps-parts)
  (hash-keys fee-deps-table))

(define (get-remaining-fee fee-v)
  (if (> (- fee-v fee-per-tx) 0)
      (- fee-v fee-per-tx)
      (if use-fee
          (raise-syntax-error 'bitml "Not enough fee provided" #f)
          0)))

(define (get-remaining-fee-split fee-v count)
  (if (> (- fee-v fee-per-tx) 0)
      (/ (- fee-v fee-per-tx) count)
      (if use-fee
          (raise-syntax-error 'bitml "Not enough fee provided" #f)
          0)))

(define (get-fee-dep-pairs)
  (for/list ([p (get-fee-deps-parts)])
    (list p (second (get-fee-dep p)))))

;clear the state
(define (reset-state)
  (set! tx-v 0)
  (set! secrets-table (make-hash))
  (set! volatile-deps-table (make-hash))
  (set! deposit-txout empty)
  (set! parts empty)
  (set! tx-index 0))

(provide (all-defined-out))