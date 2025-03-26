#lang racket

(define interactive? (not (member "-b" (current-command-line-arguments))))

; Helper function to print messages
(define (print-msg msg)
  (if interactive?
      (displayln msg)
      (displayln msg)))

; Evaluate expression with error handling
(define (evaluate expr history)
  (with-handlers ((exn:fail? (lambda (e) (print-msg "Error: Invalid Expression") 'error)))
    (let-values ([(result _) (eval-expr (string-split expr) history)])
      (if (equal? result 'error)
          (print-msg "Error: Invalid Expression")
          result))))

; Evaluate expression recursively
(define (eval-expr tokens history)
  (if (null? tokens)
      (values 'error '())
      (let ([op (car tokens)] [rest (cdr tokens)])
        (cond
          [(equal? op "+") (eval-binary + rest history)]
          [(equal? op "*") (eval-binary * rest history)]
          [(equal? op "/") (eval-binary / rest history)]
          [(equal? op "-") (eval-unary - rest history)]
          [(regexp-match #px"^\\$[0-9]+$" op) (eval-history-ref op history rest)]
          [(string->number op) (values (string->number op) rest)]
          [else (values 'error rest)]))))

; Evaluate binary operations
(define (eval-binary op tokens history)
  (let-values ([(left rest1) (eval-expr tokens history)])
    (let-values ([(right rest2) (eval-expr rest1 history)])
      (if (or (equal? left 'error) (equal? right 'error))
          (values 'error rest2)
          (if (and (equal? op /) (zero? right))
              (values 'error rest2)
              (values (op left right) rest2)))))))

; Evaluate unary operations
(define (eval-unary op tokens history)
  (let-values ([(value rest) (eval-expr tokens history)])
    (if (equal? value 'error)
        (values 'error rest)
        (values (op value) rest))))

; Evaluate history reference
(define (eval-history-ref ref history tokens)
  (let ([index (string->number (substring ref 1))])
    (if (and (<= 1 index (length history)))
        (values (list-ref history (- index 1)) tokens)
        (values 'error tokens))))

; Main loop
(define (repl-loop history)
  (print-msg "Enter an expression: ")
  (let* ([expr (read-line)]
         [result (evaluate expr history)])
    (if (not (equal? result 'error))
        (begin
          (define new-history (cons result history))
          (print-msg (format "~a: ~a" (length new-history) result))
          (repl-loop new-history))
        (repl-loop history))))

; Start the program
(define (main)
  (if interactive?
      (repl-loop '())
      (for-each (lambda (expr) (evaluate expr '())) (port->lines (current-input-port)))))

(main)
