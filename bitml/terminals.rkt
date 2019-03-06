#lang racket/base

(require (for-syntax racket/base syntax/parse))

(define-syntax (guards stx) (raise-syntax-error #f "wrong usage of guards" stx))
(define-syntax (sum stx) (raise-syntax-error #f "wrong usage of sum" stx))
(define-syntax (-> stx) (raise-syntax-error #f "wrong usage of ->" stx))


;operators for predicate in putrevealif
(define-syntax (btrue stx) (raise-syntax-error #f "wrong usage of true" stx))
(define-syntax (band stx) (raise-syntax-error #f "wrong usage of and" stx))
(define-syntax (bor stx) (raise-syntax-error #f "wrong usage of or" stx))
(define-syntax (bnot stx) (raise-syntax-error #f "wrong usage of not" stx))
(define-syntax (b= stx) (raise-syntax-error #f "wrong usage of =" stx))
(define-syntax (b!= stx) (raise-syntax-error #f "wrong usage of =" stx))
(define-syntax (b< stx) (raise-syntax-error #f "wrong usage of <" stx))
(define-syntax (b<= stx) (raise-syntax-error #f "wrong usage of <" stx))
(define-syntax (b+ stx) (raise-syntax-error #f "wrong usage of +" stx))
(define-syntax (b- stx) (raise-syntax-error #f "wrong usage of -" stx))
(define-syntax (bsize stx) (raise-syntax-error #f "wrong usage of size" stx))
(define-syntax (pred stx) (raise-syntax-error #f "wrong usage of pred" stx))

(define-syntax (strategy stx) (raise-syntax-error #f "wrong usage of strategy" stx))
(define-syntax (b-if stx) (raise-syntax-error #f "wrong usage of if" stx))  
(define-syntax (do-reveal stx) (raise-syntax-error #f "wrong usage of do-reveal" stx))
(define-syntax (do-auth stx) (raise-syntax-error #f "wrong usage of do-auth" stx))
(define-syntax (not-destory stx) (raise-syntax-error #f "wrong usage of not-destory" stx))
(define-syntax (do-destory stx) (raise-syntax-error #f "wrong usage of do-destory" stx))
(define-syntax (state stx) (raise-syntax-error #f "wrong usage of state" stx))

(define-syntax (check-liquid stx) (raise-syntax-error #f "wrong usage of check-liquid" stx))
(define-syntax (check stx) (raise-syntax-error #f "wrong usage of check" stx))
(define-syntax (has-more-than stx) (raise-syntax-error #f "wrong usage of has-more-than" stx))


(define-syntax (strip-auth stx) (raise-syntax-error #f "wrong usage of strip-auth" stx))


(provide (all-defined-out))
