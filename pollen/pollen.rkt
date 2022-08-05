#lang racket/base
(require  racket/date
          racket/match
          racket/string
          racket/list
          txexpr
          pollen/setup
          pollen/decode
          pollen/tag
          "bibtex/main.rkt")
(provide (all-defined-out))


(define num-papers (format "~a" 57))
(define num-journal-papers (format "~a" 8))

(define num-citations (format "~a" 1168))
(define h-index (format "~a" 18))
(define i10-index (format "~a" 23))
(define citations-date "26.17.2022")

(define (format-names names)
  (let* ( [reversed-list
            (reverse (map string-trim (string-split names #rx"and")))]
          [rest
            (cdr reversed-list)]
          [with-and
            (append (list (car reversed-list) "and")
                    (if (equal? (length rest) 1)
                      rest
                      (map (lambda (name) (string-append name ",")) rest)))] )
    (string-join (reverse with-and))
))

(define (format-bibtex-item item)
  (match item
    [`(,item-type ,key (,names . ,exprs) ...)
      ;;; <li>
      ;;;   {author1, author2}.
      ;;;   “{title}”.
      ;;;   In: {journal} {vol}.{num} ({year}).
      ;;; </li>
      ;;; (txexpr 'li empty '("Test"))
      (txexpr 'li empty
        (list
          (apply string-append
            (for/list ( [n names]
                        [e exprs])
              (match n
                ['author (format-names e)]
                [else ""])))
            )
      )]))

(define formated-journal-bib
  (let* ( [journal-bib
            (open-input-file "../latex/journal.bib")]
          [token-generator
            (generate-token-generator journal-bib)]
          [bibtex-ast
            (bibtex-parse token-generator)]
          [flatten-bibtex-ast
            (bibtex-flatten-strings bibtex-ast)] )
    
    (txexpr 'ul empty
      (foldl (lambda (item acc)
                (append acc (list (format-bibtex-item item))))
            empty
            flatten-bibtex-ast)
    )))
 
(module setup racket/base
  (provide (all-defined-out))
  (define poly-targets '(html ltx pdf)))
 
(define (get-date)
  (date->string (current-date)))
 
(define (heading . elems)
  (case (current-poly-target)
    [(ltx pdf) (apply string-append `("{\\huge " ,@elems "}"))]
    [else (txexpr 'h1 empty elems)]))

(define (title . elems)
  (case (current-poly-target)
    [(ltx pdf) (apply string-append `("{\\bf " ,@elems "}"))]
    [else (txexpr 'span empty elems)]))

(define (name . elems)
  (case (current-poly-target)
    [(ltx pdf) (apply string-append `("{\\bf " ,@elems "}"))]
    [else (txexpr 'name empty elems)]))

(define (emph . elems)
  (case (current-poly-target)
    [(ltx pdf) (apply string-append `("{\\bf " ,@elems "}"))]
    [else (txexpr 'strong empty elems)]))

;;; (define (root . elems)
;;;   (txexpr 'address empty (decode-elements elems
;;;      #:txexpr-elements-proc decode-paragraphs)))

(define-tag-function (section attrs elems)
  (txexpr 'h2 empty elems))

(define-tag-function (subsection attrs elems)
  (txexpr 'h3 empty elems))

(define-tag-function (hl attrs elems)
  (txexpr 'strong attrs elems))

(define-tag-function (date-list attrs elems)
  (txexpr 'dl attrs elems))

(define-tag-function (date-item attrs elems)
  (txexpr '@ empty
    (list (txexpr 'dt empty (list (attr-ref attrs 'date)))
          (txexpr 'dd empty elems))))

(define-tag-function (item-list attrs elems)
  (txexpr 'ul attrs elems))

(define-tag-function (item attrs elems)
  (txexpr 'li attrs elems))

(define-tag-function (inline-list attrs elems)
  (txexpr 'span attrs elems))
