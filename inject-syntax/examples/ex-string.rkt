#lang racket/base
(require (for-syntax racket/base) inject-syntax racket/list)

;; ----

(define-for-syntax do-require? #t)

(begin/inject-syntax
  (if do-require? #'(require racket/string) #'(begin)))

(define (my-string-join xs sep)
  (eprintf "using my string-join!\n")
  (apply string-append (add-between xs sep)))

(begin/inject-syntax
  (if (identifier-binding #'string-join)
      #'(begin)
      #'(define string-join my-string-join)))

(string-join '("hello" "world!") " ")

(define (my-string-exclaim str)
  (regexp-replace* #rx"[.]" str "!"))

(begin/inject-syntax
  (if (identifier-binding #'string-exclaim)
      #'(begin)
      #'(define string-exclaim my-string-exclaim)))

(string-exclaim "Hello. Nice to see you.")
