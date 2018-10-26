# PlagKiller
A lightweight tool to *ROUGHLY* detect of code plagiarism in Python using bash shell. 

Command needed in your linux distribution:**du, diff, cd, mkdir, echo, exit, rm, grep, wc**.

Usage:
```
chmod +x diffcheck.sh
./diffcheck.sh
```

We are going to do a 3-step check to roughly detect code plagiarism.
* Step 1: Using *diff* tool to check if two files are identical. If true, put it in a record.
* Step 2: Using *du* tool to detect hwo different two files above is. If it's different above a limit($ACCEPT_DATA_LIMIT), accept the pair.
* Step 3: Basically analyzing those two files to judge suspected code plagiarism using a line limit($REJECT_LINE_LIMIT).

**Note:** You can convert the code to detect other languages by changing the annotation flag and the $regexp.

## Update Notes:

### Version 0.3.1
* Add verification for Python file extension(.py)
* Change algorithm in Step 3 to reduce size.

### Version 0.3.0
* Initial version of Step 3 implementation.
* Change the calculating algorithm in Step 2.

### Version 0.2.0
* Initial version of Step 2 implementation.

### Version 0.1.3
* Bug fixes in Step 1.

### Version 0.1.2
* Add help notes inside the program to control better.

### Version 0.1.1
* Bug fixes in Step 1.

### Version 0.1.0
* Initial version of Step 1 implementation.

