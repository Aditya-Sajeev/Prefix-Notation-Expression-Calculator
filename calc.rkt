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

; Process the input string character by character
(define (process-string str)
  (let process ([chars (string->list str)]
                [tokens '()])
    (cond
      [(null? chars) (reverse tokens)]
      [(char-whitespace? (car chars)) (process (cdr chars) tokens)]
      [(char=? (car chars) #\+) (process (cdr chars) (cons "+" tokens))]
      [(char=? (car chars) #\*) (process (cdr chars) (cons "*" tokens))]
      [(char=? (car chars) #\/) (process (cdr chars) (cons "/" tokens))]
      [(char=? (car chars) #\-) (process (cdr chars) (cons "-" tokens))]
      [(char=? (car chars) #\$) 
       (let ([hist-idx (extract-history-index (cdr chars))])
         (process (list-tail chars (+ 1 (string-length (number->string (car hist-idx)))))
                  (cons (string-append "$" (number->string (car hist-idx))) tokens)))]
      [(char-numeric? (car chars))
       (let ([num (extract-number chars)])
         (process (list-tail chars (string-length (number->string (car num))))
                  (cons (number->string (car num)) tokens)))]
      [else (process (cdr chars) tokens)])))

; Extract a history index from a character list
(define (extract-history-index chars)
  (let extract ([remaining chars]
                [digits '()])
    (cond
      [(null? remaining) (list (string->number (list->string (reverse digits))))]
      [(char-numeric? (car remaining)) 
       (extract (cdr remaining) (cons (car remaining) digits))]
      [else (list (string->number (list->string (reverse digits))))])))

; Extract a number from a character list
(define (extract-number chars)
  (let extract ([remaining chars]
                [digits '()])
    (cond
      [(null? remaining) (list (string->number (list->string (reverse digits))))]
      [(char-numeric? (car remaining)) 
       (extract (cdr remaining) (cons (car remaining) digits))]
      [else (list (string->number (list->string (reverse digits))))])))

; Main evaluation function
(define (evaluate expr history)
  (if (string=? expr "quit")
      (begin (print-msg "Exiting...") (exit))
      (let ([tokens (process-string expr)])
        (let ([result (eval-expr tokens '() history)])
          (if (or (eq? (car result) 'error) (not (null? (cadr result))))
              (begin (print-msg "Error: Invalid Expression") 'error)
              (car result))))))

; Evaluate expressions
(define (eval-expr tokens parsed history)
  (if (null? tokens)
      (list 'error parsed)
      (let ([token (car tokens)]
            [rest (cdr tokens)])
        (cond
          [(string=? token "+") 
           (let ([left (eval-expr rest parsed history)])
             (if (eq? (car left) 'error)
                 left
                 (let ([right (eval-expr (cadr left) (cons (car left) parsed) history)])
                   (if (eq? (car right) 'error)
                       right
                       (list (+ (car left) (car right)) (cadr right))))))]
          [(string=? token "*") 
           (let ([left (eval-expr rest parsed history)])
             (if (eq? (car left) 'error)
                 left
                 (let ([right (eval-expr (cadr left) (cons (car left) parsed) history)])
                   (if (eq? (car right) 'error)
                       right
                       (list (* (car left) (car right)) (cadr right))))))]
          [(string=? token "/") 
           (let ([left (eval-expr rest parsed history)])
             (if (eq? (car left) 'error)
                 left
                 (let ([right (eval-expr (cadr left) (cons (car left) parsed) history)])
                   (if (eq? (car right) 'error)
                       right
                       (if (zero? (car right))
                           (list 'error (cadr right))
                           (list (quotient (car left) (car right)) (cadr right)))))))]
          [(string=? token "-") 
           (let ([value (eval-expr rest parsed history)])
             (if (eq? (car value) 'error)
                 value
                 (list (- (car value)) (cadr value))))]
          [(string-prefix? token "$") 
           (let ([index (string->number (substring token 1))])
             (if (and (positive? index) (<= index (length history)))
                 (list (list-ref (reverse history) (- index 1)) rest)
                 (list 'error rest)))]
          [(string->number token) (list (string->number token) rest)]
          [else (list 'error rest)]))))

; Main REPL loop
(define (repl-loop history)
  (print-msg "Enter an expression (or type 'quit' to exit): ")
  (let* ([expr (read-line)]
         [result (evaluate expr history)])
    (if (not (equal? result 'error))
        (let ([new-history (cons (real->double-flonum result) history)])
          (print-msg (format "~a: ~a" (length new-history) result))
          (repl-loop new-history))
        (repl-loop history))))

; Main program entry point
(define (main)
  (if interactive?
      (repl-loop '())
      (for-each 
       (lambda (expr) 
         (let ([result (evaluate expr '())])
           (unless (equal? result 'error)
             (display (real->double-flonum result))
             (newline))))
       (port->lines (current-input-port)))))

(main)