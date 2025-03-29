Racket Calculator

A simple calculator program written in Racket that works with Reverse Polish Notation (RPN).

Features

- Basic math operations: +, -, *, /
- Remembers previous results
- Works in interactive or batch mode

How to Use

Installation

1. Make sure Racket is installed on your system
2. Save the code as `calculator.rkt`

Running the Calculator

Interactive Mode

racket calculator.rkt

This starts the calculator where you can type expressions and see results:

Enter an expression (or type 'quit' to exit): 5 3 +
1: 8
Enter an expression (or type 'quit' to exit): 4 $1 *
2: 32
Enter an expression (or type 'quit' to exit): quit
Exiting...

Type `quit` to exit.

Batch Mode

racket calculator.rkt --batch < calculations.txt

Where `calculations.txt` contains expressions like:

5 3 +
4 $1 *

Or pipe directly:
echo "5 3 +" | racket calculator.rkt --batch


Expression Format

This calculator uses RPN format where operators come after numbers:
- `5 3 +` means 5 + 3
- `10 5 /` means 10 ÷ 5
- `$1` refers to the previous result

Examples

```
# Calculate 5 + 3, then multiply result by 4
5 3 +
4 $1 *

# Output
8
32
```
