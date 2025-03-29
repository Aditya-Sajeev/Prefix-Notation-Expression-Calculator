3/25/2025 3:34PM

This project is about making a simple calculator in Racket that uses prefix notation. Prefix notation means the operator (like +, -, *, or /) comes before the numbers. 

For example:
+ 3 4 → means 3 + 4 = 7
* 2 5 → means 2 * 5 = 10

How to Approach It:

Read User Input:
If the program runs normally, it should ask the user to enter a calculation.
If it runs in batch mode (with -b), it just prints results without extra text.

Understand the Expression:
Break the input into pieces (tokens) like +, 2, or 5.
Figure out what kind of operation it is (add, multiply, etc.).

Calculate the Result:
Perform the math based on the operator.
Handle mistakes, like dividing by zero, and print "Error: Invalid Expression" if needed.

Keep Track of Results:
Save the results in a history list so the user can reuse them later using $n (e.g., $1 means "use the first result").

Print the Result:
Show the result with its number from the history, like 1: 7 or 2: 10.


3/25/2025 3:37PM

Example Walkthrough:

User enters:
+ 2 3
Output:
1: 5

Then they enter:
* $1 4
This means multiply the previous result (5) by 4.

Output:
2: 20


3/26/2025 3:22PM

Created psuedocode for the project


3/26/2025 4:33PM

Filled in basic code for pseudocode

3/26/2025 4:54PM

Changes to history id: length is inaccurate for history id. so id is based on order of insertion/ Changes to binary operations: zero? check for division should only happen after confirmation that right operand is a number to avoid division by error / Changes to input parsing issues: Should handle whitespaces correctly and ensure expression is fully evaluated and no extra tokens are left behind / Changes to display of results: print with display and not format. Also, make sure the output includes the history id


3/26/2025 5:11PM

Added tokenize function: Handle whitespace correctly / Changes to error handling: Check for remaining tokens after evaluation / Changes to batch mode: Only result should be printed / Changes to binary operations: Correctly implemented binary operations and other functions (history reference)


3/26/2025 5:22PM

Changes to let-values: Switch to list returns / Changes to evaluate function: new return style from eval-expr / Changes to display of return: Now returns a list with two elements- the result or error and the remaining tokens / Changes to error handling: Simplified error handling to use list-based approach


3/26/2025 5:28PM

Changes to repl-loop function: Uses let to create the new-history binding, which is allowed in a expression context. Changed this due to "not allowed in an expression context in: (define new-history (cons (real->double-flonum result) history))" error


3/26/2025 5:52PM

Changes to error handling


3/26/2025 11:01PM

Changes to evaluate function


3/28/2025 6:47PM

Changes to tokenization: Process the input character by character, creates token based on a more detailed analysis of the input / Changes to evaluation: Keeps track of parsed values and uses extract-number to handle numberic values / Changes to error handling: division by zero is properly detected and invalid history id references are caught

3/28/2025 :PM

Implemented batch mode: Added process-batch-input function that properly handles batch input and maintains history between expressions and only outputs results