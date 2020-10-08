#lang racket/base

(require (for-syntax racket/function racket/base
                     syntax/apply-transformer "env.rkt")
         syntax/parse/define
         "terminals.rkt")

(provide (all-defined-out))

(define-syntax ($expand stx)
  (raise-syntax-error #f "illegal outside an ‘expand-inside’ form" stx))

(define-syntax (rngt stx)
  (raise-syntax-error #f "illegal outside an ‘expand-inside’ form" stx))


(begin-for-syntax
  (define-syntax-class do-expand-inside
    #:literals [$expand rngt]
    #:attributes [expansion]
    [pattern {~or $expand ($expand . _)}
             #:with :do-expand-inside (do-$expand this-syntax)]
    [pattern {~or rngt (rngt . _)}
             #:with :do-expand-inside (do-$expand-rngt this-syntax)]
    [pattern (a:do-expand-inside . b:do-expand-inside)
             #:attr expansion (datum->syntax (if (syntax? this-syntax) this-syntax #f)
                                             (cons (attribute a.expansion) (attribute b.expansion))
                                             (if (syntax? this-syntax) this-syntax #f)
                                             (if (syntax? this-syntax) this-syntax #f))]
    [pattern _ #:attr expansion this-syntax])
  

  (define (do-$expand stx)
    (syntax-parse stx
      [(_ {~and form {~or trans (trans . _)}})
       #:declare trans (static (disjoin procedure? set!-transformer?) "syntax transformer")
       (local-apply-transformer (attribute trans.value) #'form 'expression)]))

  (define (do-$expand-rngt stx)
    (syntax-parse stx
      [(_ {~and form {~or trans (trans . _)}})
       #:declare trans (static (disjoin procedure? set!-transformer?) "syntax transformer")
       #:with res (local-apply-transformer (attribute trans.value) #'form 'expression)
       (let ((parts (get-participants)))
       #`(auth #,@parts res))])))

(define-syntax-parser expand-inside
  #:track-literals
  [(_ form:do-expand-inside) #'form.expansion])

;; ---------------------------------------------------------------------------------------------------
#|
(define-simple-macro (symbol-binding-pairs x:id ...)
  ([x 'x] ...))
|#

(define-simple-macro (expand-expression e:expr)
  #:with result (local-expand #'e 'expression '())
  #:do [(println #'result)]
  result)

#|
(expand-expression
 (expand-inside
  (let ($expand (symbol-binding-pairs a b c))
    (list a b c))))
|#