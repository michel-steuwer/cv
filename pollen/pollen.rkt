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
  ; split string at "and", trim them, and reverse author order
  (let ([reversed-list
          (reverse (map string-trim (string-split names #rx"and")))])
    (if (equal? (length reversed-list) 1)
      ; if only one author, return it
      (car reversed-list)
      ; else, ...
      (let* ( [rest (cdr reversed-list)]
              [with-and
                ; add "and" after the last author
                (append (list (car reversed-list) "and")
                        (if (equal? (length rest) 1)
                          ; if onle one additional author, done
                          rest
                          ; else, add "," afer each additional author
                          (map (lambda (name) (string-append name ",")) rest)))] )
        ; combine all names, separated by comma and "and", re-reversed
        (string-join (reverse with-and))))))

(define (translate-bibtex-text text)
  (let ([parts (string-split text #rx"\\\\")])
    (define (replaceHighlight part)
      (let ([m (regexp-match #rx"(highlight|strongHighlight){(.*)}(.*)" part)])
        (if m
          (let* ( [hl (car (cdr m))]
                  [ms (cdr (cdr m))] )
            (txexpr '@ empty
                (list (if (equal? hl "highlight")
                        (txexpr 'em     empty (list (car ms)))
                        (txexpr 'strong empty (list (car ms))))
                      (txexpr 'span empty (cdr ms)))))
          part)))
    (map replaceHighlight parts)))

(define (format-item item formater)
  (match item
    [`(,item-type ,key (,names . ,exprs) ...)
      (define author    #f) (define title   #f) (define journal  #f)
      (define series    #f) (define volume  #f) (define number   #f)
      (define booktitle #f) (define year    #f)(define publisher #f)
      (define note      #f)
      (for/list ([n names] [e exprs])
          (match n
            ['author    (set! author    e)]
            ['title     (set! title     e)]
            ['journal   (set! journal   e)]
            ['series    (set! series    e)]
            ['volume    (set! volume    e)]
            ['number    (set! number    e)]
            ['booktitle (set! booktitle e)]
            ['publisher (set! publisher e)]
            ['year      (set! year      e)]
            ['note      (set! note      e)]
          ))
      (formater author title journal series volume
                number booktitle publisher year note)
    ])
)

(define (format-article item count)
  (txexpr '@ empty (list
    (txexpr 'dt empty (list (format "[J~a]" count)))
    (txexpr 'dd empty
      (format-item item (lambda ( author title journal series volume
                                  number booktitle publisher year note )
        (append
          (list (format-names author) ".")
          (list " “" title "”.")
          (list " In: " (txexpr 'i empty (translate-bibtex-text journal)))
          (list " " (txexpr '@ empty (translate-bibtex-text volume)))
          (list "." (txexpr '@ empty (translate-bibtex-text number)))
          (list " (" year ").")
          (if note
            (list " " (txexpr '@ empty (translate-bibtex-text note)) ".")
            empty))))))))

(define (format-paper prefix)
  (lambda (item count)
    (txexpr '@ empty (list
      (txexpr 'dt empty (list (format "[~a~a]" prefix count)))
      (txexpr 'dd empty
        (format-item item (lambda ( author title journal series volume
                                    number booktitle publisher year note )
          (append
            (list (format-names author) ".")
            (list " “" title "”.")
            (if booktitle (list " In: " (txexpr 'i empty (translate-bibtex-text booktitle)) ".") empty)
            (if volume (list " Vol. " volume ".") empty)
            (if series (list " " (txexpr '@ empty (translate-bibtex-text series)) ".") empty)
            (if publisher (list " " publisher ".") empty)
            (if note (list " " (txexpr '@ empty (translate-bibtex-text note)) ".") empty)
            ))))))))

(define (format-report prefix)
  (lambda (item count)
    (txexpr '@ empty (list
      (txexpr 'dt empty (list (format "[~a~a]" prefix count)))
      (txexpr 'dd empty
        (format-item item (lambda ( author title journal series volume
                                    number booktitle publisher year note )
          (append
            (list (format-names author) ".")
            (list " “" title "”.")
            (if journal (list " In: " (txexpr 'i empty (translate-bibtex-text journal))) empty)
            (if volume (list " " volume ".") empty)
            (list " " year ".")
            (if note (list " " (txexpr '@ empty (translate-bibtex-text note)) ".") empty)
            ))))))))

(define (formated-bib filename format-item)
  (let* ( [bib-file           (open-input-file filename)]
          [token-generator    (generate-token-generator bib-file)]
          [bibtex-ast         (bibtex-parse token-generator)]
          [flatten-bibtex-ast (bibtex-flatten-strings bibtex-ast)] )
    (define count (+ (length flatten-bibtex-ast) 1))

    (txexpr 'dl empty
      (foldl (lambda (item acc)
                (set! count (- count 1))
                (append acc (list (format-item item count))))
            empty
            flatten-bibtex-ast))))

(define formated-journal-bib
  (formated-bib "../latex/journal.bib" format-article))

(define formated-conference-bib
  (formated-bib "../latex/conference.bib" (format-paper "C")))

(define formated-workshop-bib
  (formated-bib "../latex/workshop.bib" (format-paper "W")))

(define formated-reports-bib
  (formated-bib "../latex/techreport.bib" (format-report "T")))


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

(define-tag-function (talk-list attrs elems)
  (txexpr 'dl attrs elems))

(define-tag-function (talk attrs elems)
  (txexpr '@ empty
    (list (txexpr 'dt empty (list (attr-ref attrs 'date)))
          (txexpr 'dd empty (list (attr-ref attrs 'title))))))
