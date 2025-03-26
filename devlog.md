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

Filled in code for pseudocode

3/26/2025 4:54PM

Changes to history id / Changes to binary operations / Changes to input parsing issues / Changes to display of results


3/26/2025 5:11PM

Added tokenize function / Changes to error handling / Changes to batch mode / Changes to binary operations