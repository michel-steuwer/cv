#lang racket/base

(require "bibtex/main.rkt")


(define bibtex-input-port (current-input-port))

(define token-generator (generate-token-generator bibtex-input-port))
(bibtex-parse token-generator)
