#lang info

;; pkg info

(define version "1.0")
(define collection "inject-syntax")
(define deps '("base" "inject-syntax-lib"))
(define build-deps '("racket-doc" "scribble-lib"))
(define implies '("inject-syntax-lib"))
(define pkg-authors '(ryanc))

;; collection info

(define name "inject-syntax")
(define scribblings '(("inject-syntax.scrbl" ())))

(define compile-omit-paths '("examples"))
(define test-omit-paths '("examples"))
