#lang scribble/manual
@(require (for-label racket/base racket/require inject-syntax)
          scribble/example)

@title[#:version "1.0"]{inject-syntax: Immediate Compile-time Code Injection}
@author[@author+email["Ryan Culpepper" "ryanc@racket-lang.org"]]

@(define (expected-in-future-version)
   (cond [(regexp-match #rx"^([0-9]+)[.]" (version))
          => (lambda (m)
               (format "expected in Racket ~a.3"
                       (+ 1 (string->number (cadr m)))))]
         [else "12.0"]))

@(begin
   (define the-eval (make-base-eval))
   (the-eval '(require inject-syntax)))

@defmodule[inject-syntax]

This module provides forms that allow programmers to escape to
compile-time, compute code, and inject it at the site of the escape
form. This is often called @index['("splice" "splicing")]{splicing} in
other metaprogramming systems, but in Racket the term ``splicing'' is
already heavily overloaded: @racketmodname[racket/splicing],
@racket[begin]-splicing, @racket[unquote-splicing], etc.

The effect of @racket[begin/inject-syntax] is similar to an immediate
application of an anonymous macro, except that no macro scope is added
to the resulting syntax.

One use of @racket[begin/inject-syntax] is to conditionally define or
require workarounds depending on whether identifiers are bound in the
current environment. For example:

@examples[#:eval the-eval #:label #f
(require (for-syntax racket/base) inject-syntax racket/string)
(begin/inject-syntax
  (if (identifier-binding #'string-join)
      #'(begin)
      #'(begin
         (require (only-in racket/list add-between))
         (define (string-join xs sep)
           (apply string-append (add-between xs sep))))))
(string-join '("one" "two" "three") " and a ")

(begin/inject-syntax
  (if (identifier-binding #'string-exclaim) (code:comment #,(expected-in-future-version))
      #'(begin)
      #'(define (string-exclaim str)
          (regexp-replace* #rx"[.]" str "!"))))
(string-exclaim "Thanks. Have a nice day.")
]

A variation on the previous example is to select between different
implementations (eg, safe vs unsafe or with contracts vs without
contracts) based on compile-time configuration variables. For example:

@examples[#:eval the-eval #:label #f
(require racket/require)
(define-for-syntax use-safe-fx-ops? #t)
(begin/inject-syntax
  (if use-safe-fx-ops?
      #'(require (prefix-in unsafe- racket/fixnum))
      #'(require (matching-identifiers-in #rx"^unsafe-fx" racket/unsafe/ops))))
(unsafe-fx+ 1 2)
]


@bold{Warning:} Code can be run on a different platform from the one
it was compiled on. Don't use compile-time conditions to specialize
code based on features such as the size of fixnums, the operating
system, path conventions, and so on, because these may change between
compile time and run time.


@defform[(begin/inject-syntax body ...+)]{

Evaluates the @racket[body] forms at compile time. The @racket[body]s
must end in an expression that produces a syntax object; otherwise, a
syntax error is raised. The syntax object result replaces the
@racket[begin/inject-syntax] form.

Any side-effects performed by the @racket[body]s occur only once, when
the @racket[begin/inject-syntax] form is compiled. This is in contrast
to @racket[begin-for-syntax], whose contents are also evaluated when
the enclosing module is visited.
}

@defform[(expression/inject-syntax body ...+)]{

Equivalent to @racket[(#%expression (begin/inject-syntax body ...))].
}


@(close-eval the-eval)
