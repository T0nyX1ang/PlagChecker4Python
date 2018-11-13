# PlagChecker4Python
A lightweight tool to *ROUGHLY* detect of code plagiarism in Python using bash shell. 

Command needed in your linux distribution:**cd, diff, echo, exit, find, grep, wc**.

Release version 1.0.0 is coming.

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

## Update Notes:

### Version 1.0.0
* Rearrange message displaying styles.
* Change help message displaying styles.
* Delete redundant codes in $REJECT_LINE_SCORE.
* Merging GVdiffcheck.sh with original diffcheck.sh to make it run faster.
* Deleting step 2 because of its bad performance.
* Combining 3 steps to *ONE* step.
* Using pipes instead of creating new folders to save I/O.
* Remove log files because of low usage, and it's replaced by the summary lines.
* Change final screen flushing time.
* Change README documents.

### Version 0.5.6
* Use functions instead of pipes to show messages. Thus a few codes have been changed.
* Remove some redundant lines.
* **Notice: GVdiffcheck.sh will be merged into main file diffcheck.sh in next version. According to the speed check, it is faster than the original files by 10%.**

### Version 0.5.5
* Change methods to judge total files.
* **Notice: We are developing a method to merge those steps together and make our codes simpler, so here is our testing file: GVdiffcheck.sh, which means Grep Version of diffcheck. Those pipes really hit us a lot.**

### Version 0.5.4
* Making help lines in a function to shorten codes.
* Changing the code to fit in with more parameters. Note that you only need to follow the rules, and **latest instructions will override old ones.** Here is an example:
```bash
./diffcheck.sh -l -q -u -v -u -n -S=96 -s 
```
is equal to 
```bash
./diffcheck.sh -u -s
```
* Using new condition branchs to detect parameters to shorten codes.

### Version 0.5.3
* Add more detailed statistics descriptions in the summary and somewhat change the format.
* **NOTICE: The final version is coming soon, after those parameters are working fine after simplifying some codes.**

### Version 0.5.2
* Add a $FORMATTER to take place in displaying messages instead of using if-condition clauses. (Although this operation will make the process a bit longer.)
* Recover the styles of displaying messages in **Version 0.4.1.**

### Version 0.5.1
* Add a feature to let user decide $REJECT_LINE_SCORE. And if this fails, an error message will be shown.
* Enable colors in parameter checking.
* Change message displays in quiet mode(-q), showing those error messages now.

### Version 0.5.0
* Make parameters to let user judge checking criterion. You can use -q/u/v to adjust **verbosity**, -l/n/s to adjust **$REJECT_LINE_SCORE**, -h to invoke **help**. Default criterion will be -u -v (if you use it as before). See help to get more infomation.
* Change some infomation conditions according to the parameter.
* Add a help inside the program.
* **NOTICE: The increasing code lines are really annoying. We are planning to use another language with the core features in the program in future versions.**

### Version 0.4.1
* Fix a typo.
* Fix a *critical* bug which causes failure to detect copyer and copyee.

### Version 0.4.0
* Fix a bug in color demonstration.
* Add a summary feature by comparing last modified time to conduct the copyer and copyee.
* Remove the sleeping feature when detecting a plagiarism code and substitute it with a screen clear.
* **NOTICE: We will make parameters to let user judge checking criterion.**

### Version 0.3.3
* Set bash directory to /bin/bash
* Change default $REJECT_LINE_SCORE to 70.
* Enable colors to extinguish different message types. [**Info**] is green. [**Suspected**] is yellow. [**Detected**] and [**Error**] is red.

### Version 0.3.2
* Fix a bug in detecting and deleting log files.
* Change methods in detecting suspected plagiarism in Step 3. Use scores to judge.
* Change a bit of log file contents.
* **NOTICE: There is a potential defect: this code can't detect spaces well, so a file with elaborated construction might go wrong in certain cases. Handle this with care!**

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

