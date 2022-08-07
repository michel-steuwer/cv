#lang racket/base
(require  racket/date
          racket/match
          racket/string
          racket/list
          txexpr
          xml
          pollen/setup
          pollen/decode
          pollen/tag
          "bibtex/main.rkt")
(provide (all-defined-out))


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
      (define author    #f) (define title   #f) (define journal   #f)
      (define series    #f) (define volume  #f) (define number    #f)
      (define booktitle #f) (define year    #f) (define publisher #f)
      (define note      #f) (define editor  #f) (define school    #f)
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
            ['editor    (set! editor    e)]
            ['school    (set! school    e)]
          ))
      (formater author title journal series volume
                number booktitle publisher year note editor school)
    ])
)

(define (format-article item count)
  (txexpr '@ empty (list
    (txexpr 'dt '((class "label")) (list (format "[J~a]" count)))
    (txexpr 'dd empty
      (format-item item (lambda ( author title journal series volume
                                  number booktitle publisher year note editor school )
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
      (txexpr 'dt '((class "label")) (list (format "[~a~a]" prefix count)))
      (txexpr 'dd empty
        (format-item item (lambda ( author title journal series volume
                                    number booktitle publisher year note editor school )
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
      (txexpr 'dt '((class "label")) (list (format "[~a~a]" prefix count)))
      (txexpr 'dd empty
        (format-item item (lambda ( author title journal series volume
                                    number booktitle publisher year note editor school )
          (append
            (list (format-names author) ".")
            (list " “" title "”.")
            (if journal (list " In: " (txexpr 'i empty (translate-bibtex-text journal))) empty)
            (if volume (list " " volume ".") empty)
            (if school (list " " (txexpr '@ empty (translate-bibtex-text school)) ".") empty)
            (list " " year ".")
            (if note (list " " (txexpr '@ empty (translate-bibtex-text note)) ".") empty)
            ))))))))

(define (format-chapter prefix)
  (lambda (item count)
    (txexpr '@ empty (list
      (txexpr 'dt '((class "label")) (list (format "[~a~a]" prefix count)))
      (txexpr 'dd empty
        (format-item item (lambda ( author title journal series volume
                                    number booktitle publisher year note editor school )
          (append
            (list (format-names author) ".")
            (list " “" title "”.")
            (if booktitle (list " In: " (txexpr 'i empty (translate-bibtex-text booktitle)) ".") empty)
            (if editor (list " Ed. by" editor ".") empty)
            (if volume (list " Vol. " volume ".") empty)
            (if series (list " " (txexpr '@ empty (translate-bibtex-text series)) ".") empty)
            (if publisher (list " " publisher ".") empty)
            (if note (list " " (txexpr '@ empty (translate-bibtex-text note)) ".") empty)
            ))))))))

(define (count-items filename)
  (let* ( [bib-file           (open-input-file filename)]
          [token-generator    (generate-token-generator bib-file)]
          [bibtex-ast         (bibtex-parse token-generator)] )
    (length bibtex-ast)))

(define (formated-bib filename format-item)
  (let* ( [bib-file           (open-input-file filename)]
          [token-generator    (generate-token-generator bib-file)]
          [bibtex-ast         (bibtex-parse token-generator)]
          [flatten-bibtex-ast (bibtex-flatten-strings bibtex-ast)] )
    (define count (+ (length flatten-bibtex-ast) 1))

    (txexpr 'dl '((class "bib"))
      (foldl (lambda (item acc)
                (set! count (- count 1))
                (append acc (list (format-item item count))))
            empty
            flatten-bibtex-ast))))

(define journal-bib "../latex/journal.bib")
(define num-journal-papers (count-items journal-bib))
(define formated-journal-bib
  (formated-bib journal-bib format-article))

(define conference-bib "../latex/conference.bib")
(define num-conference-papers (count-items conference-bib))
(define formated-conference-bib
  (formated-bib conference-bib (format-paper "C")))

(define workshop-bib "../latex/workshop.bib")
(define num-workshop-papers (count-items workshop-bib))
(define formated-workshop-bib
  (formated-bib workshop-bib (format-paper "W")))

(define report-bib "../latex/techreport.bib")
(define num-reports (count-items report-bib))
(define formated-reports-bib
  (formated-bib report-bib (format-report "T")))

(define chapter-bib "../latex/chapter.bib")
(define num-chapters (count-items chapter-bib))
(define formated-chapters-bib
  (formated-bib chapter-bib (format-chapter "B")))

(define thesis-bib "../latex/thesis.bib")
(define formated-thesis-bib
  (formated-bib thesis-bib (format-report "TH")))

(define num-papers
  (+ num-journal-papers num-conference-papers num-workshop-papers num-reports num-chapters))

(define num-citations (format "~a" 1168))
(define h-index (format "~a" 18))
(define i10-index (format "~a" 23))
(define citations-date "26.17.2022")

(module setup racket/base
  (provide (all-defined-out))
  (define poly-targets '(html ltx pdf)))
 
(define (get-date)
  (date->string (current-date)))
 
;;; (define (heading . elems)
;;;   (case (current-poly-target)
;;;     [(ltx pdf) (apply string-append `("{\\huge " ,@elems "}"))]
;;;     [else (txexpr 'h1 empty elems)]))

;;; (define (title . elems)
;;;   (case (current-poly-target)
;;;     [(ltx pdf) (apply string-append `("{\\bf " ,@elems "}"))]
;;;     [else (txexpr 'span empty elems)]))

;;; (define (name . elems)
;;;   (case (current-poly-target)
;;;     [(ltx pdf) (apply string-append `("{\\bf " ,@elems "}"))]
;;;     [else (txexpr 'name empty elems)]))

(define (emph . elems)
  (case (current-poly-target)
    [(ltx pdf) (apply string-append `("{\\bf " ,@elems "}"))]
    [else (txexpr 'strong empty elems)]))

(define-tag-function (heading attrs elems)
  (txexpr '@ empty (list
    (txexpr 'div '((id "heading")) (list
      (txexpr 'h1 empty (list
        (txexpr 'span empty (list (attr-ref attrs 'title)))
        (attr-ref attrs 'name)))
      (txexpr 'address empty (decode-elements elems
        #:txexpr-elements-proc decode-paragraphs))))
    (txexpr 'div '((style "clear: both;")) empty))))

(define-tag-function (email attrs elems)
  (let ([mail (car elems)])
    (string->xexpr (format
      "<a href=\"mailto:~a\"><i class=\"icon fa-envelope\"></i> ~a</a>" mail mail))))

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
  (txexpr 'ul '((class "inline"))
    (let ([ll (foldl (lambda (elem acc)
                (if (and (string? elem) (string=? elem "\n"))
                  (append acc (list empty)) ; add new empty list at the end
                  (list-update acc (- (length acc) 1) (lambda (lst) (append lst (list elem))))))
              (list empty)
              elems)])
      (map (lambda (lst) (txexpr 'li empty lst)) ll))))

(define-tag-function (talk-list attrs elems)
  (txexpr 'dl attrs elems))

(define-tag-function (talk attrs elems)
  (txexpr '@ empty
    (list (txexpr 'dt empty (list (attr-ref attrs 'date)))
          (txexpr 'dd empty (list (attr-ref attrs 'title))))))

(define-tag-function (student-list attrs elems)
  (txexpr 'dl attrs elems))

(define-tag-function (student attrs elems)
  (txexpr '@ empty
    (list (txexpr 'dt empty (list (attr-ref attrs 'date)))
          (txexpr 'dd empty (list 
            (txexpr 'div '((class "left")) (list (attr-ref attrs 'name)))
            (txexpr 'div '((class "right")) (list
              (if (attrs-have-key? attrs 'together-with)
                (txexpr 'span '((class "even-smaller")) (list "together with " (attr-ref attrs 'together-with) ", "))
                (txexpr '@ empty empty)
              )
              (if (attrs-have-key? attrs 'main-supervisor)
                (txexpr 'span '((class "even-smaller")) (list "main supervisor " (attr-ref attrs 'main-supervisor) ", "))
                (txexpr '@ empty empty)
              )
              (attr-ref attrs 'institution)
            ))
            (txexpr 'div '((class "smaller") (style "clear: both;")) elems)
            (if (attrs-have-key? attrs 'now)
              (txexpr 'div empty (list "Now " (attr-ref attrs 'now) "."))
              (txexpr '@ empty empty))
          )))))

(define-tag-function (smaller attrs elems)
  (txexpr 'span '((class "smaller")) elems))

(define-tag-function (even-smaller attrs elems)
  (txexpr 'span '((class "even-smaller")) elems))

(define-tag-function (line attrs elems)
  (txexpr 'div '((class "line")) elems))
;;; (define (root . elements)
;;;    (txexpr 'root empty (decode-elements elements
;;;      #:txexpr-elements-proc decode-paragraphs)))