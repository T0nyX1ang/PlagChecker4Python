#!/bin/bash

# Define colors
readonly CRed="\e[0;31m";
readonly CGrn="\e[0;32m";
readonly CYel="\e[0;33m";
readonly CClr="\e[0m";

# Define help function
function print_help() {
	# Print help 
	echo -e "Plagiarism Checker for Python";
	echo -e "A lightweight tool to detect structure of code plagiarism.";
	echo -e "Written by Tony Xiang.\n";
	echo -e "Usage: ./diffcheck.sh [parameters]\n";
	echo -e "The parameters should follow like this: -verbosity[-q/u/v] -strictness[-l/n/s/S=0-100] \n";
	echo -e "Verbosity options:";
	echo -e "  -q Quiet mode. Will not generate messages. Only summary and error message will be shown.";
	echo -e "  -u Urgent-only mode. Will generate urgent(Detected/Suspected/Error) messages. [Default]";
	echo -e "  -v Verbose mode. Will generate full(Detected/Suspected/Error/Info) messages.\n";
	echo -e "Strictness options:";
	echo -e "  -l Loose mode. Files lower than 60 scores will be judged as suspected.";
	echo -e "  -n Normal mode. Files lower than 70 scores will be judged as suspected. [Default]";
	echo -e "  -s Strict mode. Files lower than 80 scores will be judged as suspected.";
	echo -e "  -S Score mode. You can specify your score limit with -S=[your score]."
	exit;
}

# Parameters and syntax check. Latest parameters will override old ones.
FORMATTER="";
REJECT_LINE_SCORE=-1;
for param in $@; do
	case "${param#*-}" in
		h* )
			print_help;
			;;
		q )
			FORMATTER="['[']Error";
			;;
		u )
			FORMATTER="['['][SED][ure][srt][poe]";
			;;
		v )
			FORMATTER="['[''][ISED][nure][fsrt][ope]";
			;;
		l )
			REJECT_LINE_SCORE=60;
			;;
		n )
			REJECT_LINE_SCORE=70;
			;;
		s )
			REJECT_LINE_SCORE=80;
			;;
		S* )
			temp=${param##*=};
			if [ -n "$temp" -a "$temp" = "${temp//[^0-9]/}" ] && [ $temp -ge 0 ] && [ $temp -le 100 ]; then
				REJECT_LINE_SCORE=$temp;
			else
				echo -e "${CRed}[Error] Invalid syntax or format in inputting scores.$CClr\n";
				print_help;
			fi
			;;
		* )
			echo -e "${CRed}[Error] Wrong parameter. Please see the help below.$CClr\n";
			print_help;
			;;
	esac
done

if [[ "$FORMATTER" == "" ]]; then
	FORMATTER="['['][SED][ure][srt][poe]";
fi

if [ $REJECT_LINE_SCORE == -1 ]; then
	REJECT_LINE_SCORE=70;
fi

# Basic stats.
TOTAL_FILES=`ls -1 -l | grep ^- | wc -l`;
VALID_FILES=`ls -1 | grep .py$ | wc -l`;
((CHECKED_PAIRS=$VALID_FILES*($VALID_FILES-1)/2));
FATAL_PAIRS=0;
SUMMARY_LINE="Summary of files: ";

# Main process goes here.
for i in `ls -1 | grep .py$ `; do
	for j in `ls -1 | grep .py$ `; do
		if [[ "$i" < "$j" ]]; then

			# Step 1
			echo -e "${CGrn}[Info] Evaluating file lines of $i.$CClr" | grep "$FORMATTER";
			FILE_1_LINES=`grep ^[a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$i" | wc -l`;
			echo -e "${CGrn}[Info] Evaluating file lines of $j.$CClr" | grep "$FORMATTER";
			FILE_2_LINES=`grep ^[a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$j" | wc -l`;

			echo -e "${CGrn}[Info] Comparing $i and $j.$CClr" | grep "$FORMATTER";
			echo -e "${CGrn}[Info] Stage 1: Checking those files line by line.$CClr" | grep "$FORMATTER";
			# Suppressing all white spaces(-w), blank lines(-B), sensitive cases(-i) and annotations(-I '^#').
			# Making an unified 'diff' output here. Use pipes to connect file streams.
			FILE_1_DIFFERENT_LINES=`diff -w -B -i -I '^#' -u "$i" "$j" | grep ^[-][a-zA-Z0-9_=" "\*\&\(\)\$"	"] | wc -l`;
			FILE_2_DIFFERENT_LINES=`diff -w -B -i -I '^#' -u "$i" "$j" | grep ^[+][a-zA-Z0-9_=" "\*\&\(\)\$"	"] | wc -l`;
			((FILE_1_SCORE=$FILE_1_DIFFERENT_LINES*100/FILE_1_LINES));
			((FILE_2_SCORE=$FILE_2_DIFFERENT_LINES*100/FILE_2_LINES));

			if [ $FILE_1_SCORE -ge $REJECT_LINE_SCORE ] || [ $FILE_2_SCORE -ge $REJECT_LINE_SCORE ]; then
				echo -e "${CGrn}[Info] Comparing $i $j OK!$CClr" | grep "$FORMATTER";
				continue;
			fi

			echo -e "${CYel}[Suspected] Suspected plagiarism detected. Different lines lower than the limit.$CClr" | grep "$FORMATTER";
			((FATAL_PAIRS=$FATAL_PAIRS+1))

			# Step 2
			echo -e "${CGrn}[Info] Stage 2: Comparing last modified time.$CClr" | grep "$FORMATTER";
			if [[ `find $i -newer $j` == $i ]]; then
				SUMMARY_LINE=$SUMMARY_LINE"\nSuspected/Detected plagiarism: ${CGrn}$j$CClr->${CRed}$i$CClr [$FILE_2_SCORE:$FILE_1_SCORE].";
			else
				SUMMARY_LINE=$SUMMARY_LINE"\nSuspected/Detected plagiarism: ${CGrn}$i$CClr->${CRed}$j$CClr [$FILE_1_SCORE:$FILE_2_SCORE].";
			fi

		fi
	done
done

echo -e "${CGrn}[Info] Clearing screen ... $CClr" | grep "$FORMATTER";
sleep 3;
clear;
echo -e "------ SUMMARY ------";
echo -e "${VALID_FILES} valid files out of ${TOTAL_FILES} files.";
echo -e "${FATAL_PAIRS} suspected/detected plagiarism pairs out of ${CHECKED_PAIRS} pairs.";
echo -e "---------------------";
echo -e "$SUMMARY_LINE";
