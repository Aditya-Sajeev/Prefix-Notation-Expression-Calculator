#lang racket

; Determine mode using command-line arguments
(define interactive?
  (let ([args (current-command-line-arguments)])
    (cond
      [(= (vector-length args) 0) #t]  ; Default to interactive if no args
      [(string=? (vector-ref args 0) "-b") #f]  ; Batch mode
      [(string=? (vector-ref args 0) "--batch") #f]  ; Batch mode
      [else #t])))  ; Default to interactive mode

; Helper function to print messages (only in interactive mode)
(define (print-msg msg)
  (when interactive? (displayln msg)))

; Tokenize the input expression
(define (tokenize expr)
  (let loop ([chars (string->list expr)]
             [current-token '()]
             [tokens '()])
    (cond
      [(null? chars)
       (reverse (if (null? current-token)
                    tokens
                    (cons (list->string (reverse current-token)) tokens)))]
      [(char-whitespace? (car chars))
       (loop (cdr chars)
             '()
             (if (null? current-token)
                 tokens
                 (cons (list->string (reverse current-token)) tokens)))]
      [else
       (loop (cdr chars)
             (cons (car chars) current-token)
             tokens)])))

; Evaluate expression with error handling
(define (evaluate expr history)
  (if (string=? expr "quit")
      (begin (print-msg "Exiting...") (exit))  ; Exit if expr is "quit"
      (with-handlers 
        [(exn:fail? 
          (lambda (e) 
            (print-msg "Error: Invalid Expression")
            'error))]
        (let-values ([(result remaining-tokens)] 
                     (eval-expr (map symbol->string (tokenize expr)) history)))
          (if (or (equal? result 'error) (not (null? remaining-tokens)))
              (begin 
                (print-msg "Error: Invalid Expression") 
                'error)
              result))))

; Evaluate expression recursively
(define (eval-expr tokens history)
  (if (null? tokens)
      (values 'error '())  ; Return error if tokens are empty
      (let ([op (car tokens)] [rest (cdr tokens)])
        (cond
          [(string=? op "+") (eval-binary + rest history)]  ; Evaluate addition
          [(string=? op "*") (eval-binary * rest history)]  ; Evaluate multiplication
          [(string=? op "/") (eval-binary / rest history)]  ; Evaluate division
          [(string=? op "-") (eval-unary - rest history)]  ; Evaluate unary negation
          [(regexp-match #px"^\\$[0-9]+$" op) (eval-history-ref op history rest)]  ; History reference
          [(string->number op) (values (string->number op) rest)]  ; Convert to number if possible
          [else (values 'error rest)]))))  ; If invalid operator, return error

; Evaluate binary operations
(define (eval-binary op tokens history)
  (let-values ([(left rest1) (eval-expr tokens history)])
    (let-values ([(right rest2) (eval-expr rest1 history)])
      (if (or (equal? left 'error) (equal? right 'error))
          (values 'error rest2)
          (if (and (equal? op /) (zero? right))  ; Handle division by zero
              (values 'error rest2)
              (values (op left right) rest2))))))

; Evaluate unary operations
(define (eval-unary op tokens history)
  (let-values ([(value rest) (eval-expr tokens history)])
    (if (equal? value 'error)
        (values 'error rest)
        (values (op value) rest))))

; Evaluate history reference
(define (eval-history-ref ref history tokens)
  (let ([index (string->number (substring ref 1))])  ; Get the index from $n
    (if (and (<= 1 index (length history)))
        (values (list-ref (reverse history) (- index 1)) tokens)  ; Retrieve history value
        (values 'error tokens))))  ; Return error if index is out of range

; Main loop
(define (repl-loop history)
  (print-msg "Enter an expression (or type 'quit' to exit): ")
  (let* ([expr (read-line)]
         [result (evaluate expr history)])
    (if (not (equal? result 'error))
        (begin
          (define new-history (cons (real->double-flonum result) history))  ; Add result to history
          (print-msg (format "~a: ~a" (length new-history) result))  ; Display result with history id
          (repl-loop new-history))  ; Continue loop with updated history
        (repl-loop history))))  ; Keep current history on error

; Start the program
(define (main)
  (if interactive?
      (repl-loop '())  ; Start in interactive mode
      (for-each 
       (lambda (expr) 
         (let ([result (evaluate expr '())])
           (unless (equal? result 'error)
             (display (real->double-flonum result))
             (newline))))
       (port->lines (current-input-port)))))  ; Batch mode

(main)