#lang racket/base

(require (for-syntax racket/base syntax/parse))

(define-syntax (pre stx) (raise-syntax-error #f "wrong usage of pre" stx))
(define-syntax (sum stx) (raise-syntax-error #f "wrong usage of sum" stx))
(define-syntax (-> stx) (raise-syntax-error #f "wrong usage of ->" stx))
(define-syntax (putrevealif stx) (raise-syntax-error #f "wrong usage of putrevealif" stx))
(define-syntax (put stx) (raise-syntax-error #f "wrong usage of put" stx))
(define-syntax (revealif stx) (raise-syntax-error #f "wrong usage of revealif" stx))
(define-syntax (reveal stx) (raise-syntax-error #f "wrong usage of reveal" stx))
(define-syntax (split stx) (raise-syntax-error #f "wrong usage of split" stx))
(define-syntax (withdraw stx) (raise-syntax-error #f "wrong usage of withdraw" stx))
(define-syntax (after stx) (raise-syntax-error #f "wrong usage of after" stx))
(define-syntax (auth stx) (raise-syntax-error #f "wrong usage of auth" stx))
(define-syntax (tau stx) (raise-syntax-error #f "wrong usage of tau" stx))

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
(define-syntax (between stx) (raise-syntax-error #f "wrong usage of between" stx))

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
