# PlagChecker4Python
A lightweight tool to *ROUGHLY* detect of code plagiarism in Python using bash shell. 

Command needed in your linux distribution:**cd, diff, echo, exit, find, grep, wc**.

Usage:
```bash
chmod +x diffcheck.sh
./diffcheck.sh 
or 
./diffcheck.sh -q/u/v -l/n/s/S=score
```

We are going to do a 2-step check to roughly detect code plagiarism.

* Step 1: Using *diff* tool to check if two files are identical, and basically analyzing those two files to judge suspected code plagiarism using a line limit($REJECT_LINE_SCORE).
* Step 2: Detect copyer and copyee by comparing their last modified time.

**Note:** You can convert the code to detect other languages by changing the annotation flag and the regular expressions in the source code.

