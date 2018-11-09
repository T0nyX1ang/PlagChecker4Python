#!/bin/bash

# signed gpg commits for tests. 12345678911111

# Parameters and syntax check.
if [[ $1 == "-h" ]]; then
	# Print help 
	echo -e "Plagiarism Checker for Python";
	echo -e "A lightweight tool to detect structure of code plagiarism.";
	echo -e "Written by Tony Xiang.\n";
	echo -e "Usage: ./diffcheck.sh [parameters]\n";
	echo -e "The parameters should follow like this: -verbosity[-q/u/v] -strictness[-l/n/s] \n";
	echo -e "Verbosity options:";
	echo -e "\t-q Quiet mode. Will not generate messages. Only summary will be shown.";
	echo -e "\t-u Urgent-only mode. Will generate urgent(Detected/Suspected/Error) messages. [Default]";
	echo -e "\t-v Verbose mode. Will generate full(Detected/Suspected/Error/Info) messages.\n";
	echo -e "Strictness options:";
	echo -e "\t-l Loose mode. Files lower than 60 scores will be judged as suspected.";
	echo -e "\t-n Normal mode. Files lower than 70 scores will be judged as suspected. [Default]";
	echo -e "\t-s Strict mode. Files lower than 80 scores will be judged as suspected.";
	exit
elif [[ $1 == "-q" ]] || [[ $1 == "-u" ]] || [[ $1 == "-v" ]]; then
	readonly VERBOSITY=$1;
	if [[ $2 == "-l" ]] || [[ $2 == "-n" ]] || [[ $2 == "-s" ]]; then
		readonly STRICTNESS=$2;
	elif [[ $2 == "" ]]; then
		readonly STRICTNESS="-n";
	else
		echo -e "Invalid syntax.\n";
		exit
	fi
elif [[ $1 == "-l" ]] || [[ $1 == "-n" ]] || [[ $1 == "-s" ]]; then
	readonly STRICTNESS=$1;
	if [[ $2 == "-q" ]] || [[ $2 == "-u" ]] || [[ $2 == "-v" ]]; then
		readonly VERBOSITY=$2;
	elif [[ $2 == "" ]]; then
		readonly VERBOSITY="-u";
	else
		echo -e "Invalid syntax.\n";
		exit
	fi
elif [[ $1 == "" ]]; then
	readonly VERBOSITY="-u";
	readonly STRICTNESS="-n";
else
	echo -e "Invalid syntax. \n";
	exit
fi

WORKING_DIR=".";
TESTING_DIR="COMPARE_TESTS";
ACCEPT_DATA_LIMIT=300;
if [[ "$STRICTNESS" == "-l" ]]; then
	REJECT_LINE_SCORE=60;
elif [[ "$STRICTNESS" == "-n" ]]; then
	REJECT_LINE_SCORE=70;
elif [[ "$STRICTNESS" == "-s" ]]; then
	REJECT_LINE_SCORE=80;
fi


# Define colors
readonly CRed="\e[0;31m"
readonly CGrn="\e[0;32m"
readonly CYel="\e[0;33m"
readonly CClr="\e[0m"

SUMMARY_LINE="Summary of files: ";

# Check if testing directory exists.
if [[ ! -d "$TESTING_DIR" ]]; then
	if [[ "$VERBOSITY" == "-v" ]]; then
		echo -e "${CGrn}[Info] Creating testing directory.$CClr";
	fi
	mkdir $TESTING_DIR;
fi

# Check if working and testing directory writable.
if [[ ! -w "$TESTING_DIR" ]] || [[ ! -w "$WORKING_DIR" ]]; then
	# Output an error if permission denied.
	echo -e "${CRed}[Error] Permission Denied! Check your permission first.$CClr";
	exit;
fi

if [[ -f "$TESTING_DIR/log.txt" ]]; then
	if [[ "$VERBOSITY" == "-v" ]]; then
		echo -e "${CGrn}[Info] Deleting existing log file.$CClr";
	fi
	rm "$TESTING_DIR/log.txt";
fi

for i in `ls -1 | grep .py$ `; do
	for j in `ls -1 | grep .py$ `; do
		if [[ "$i" < "$j" ]] && [[ "$i" != "diffcheck.sh" ]] && [[ "$j" != "diffcheck.sh" ]] && [[ "$i" != "$TESTING_DIR" ]] && [[ "$j" != "$TESTING_DIR" ]]; then
			COMPARE_FILE="$i""_COMPARE_""$j"".txt";

			if [[ "$VERBOSITY" == "-v" ]]; then
				echo -e "${CGrn}[Info] Evaluating file sizes of $i.$CClr";
				echo -e "${CGrn}[Info] Evaluating file lines of $i.$CClr";
				echo -e "${CGrn}[Info] Evaluating file sizes of $j.$CClr";
				echo -e "${CGrn}[Info] Evaluating file lines of $j.$CClr";
				echo -e "${CGrn}[Info] Comparing $i and $j.$CClr";
				echo -e "${CGrn}[Info] Stage 1: Checking if two files are identical.$CClr";
			fi
			
			# Step 1
			ORIG_FILE_1_SIZE=`du -h -b "$i"`;
			FILE_1_SIZE=${ORIG_FILE_1_SIZE%%	*};
			FILE_1_LINES=`grep ^[a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$i" | wc -l`;
			ORIG_FILE_2_SIZE=`du -h -b "$j"`;
			FILE_2_SIZE=${ORIG_FILE_2_SIZE%%	*};
			FILE_2_LINES=`grep ^[a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$j" | wc -l`;
			
			cd "$TESTING_DIR";
			# Suppressing all white spaces(-w), blank lines(-B), sensitive cases(-i) and annotations(-I '^#').
			# Making an unified 'diff' output here.
			diff -w -B -i -I '^#' -u "../""$i" "../""$j" > "$COMPARE_FILE";

			if [[ ! -s "$COMPARE_FILE" ]]; then
				if [[ "$VERBOSITY" != "-q" ]]; then
					echo -e "${CRed}[Detected] Plagiarism detected. Identical files found!$CClr";
				fi
				if [[ "$VERBOSITY" == "-v" ]]; then
					echo -e "${CGrn}[Info] Saving file digest to log.$CClr";
				fi
				echo -e "Plagiarism detected. Identical files found!" >> "log.txt";
				echo -e "-------- File Digest Separator --------" >> "log.txt";
				echo -e "#1 Filename: $i::File #1 lines: $FILE_1_LINES::Different lines: 0::Score = 0." >> "log.txt";
				echo -e "#2 Filename: $j::File #2 lines: $FILE_2_LINES::Different lines: 0::Score = 0." >> "log.txt";
				echo -e "" >> "log.txt";
				cd "..";
				continue;
			fi
			
			# Step 2
			if [[ "$VERBOSITY" == "-v" ]]; then
				echo -e "${CGrn}[Info] Stage 2: Checking if the difference of those files are above limit.$CClr";
			fi

			ORIG_COMPARE_SIZE=`du -h -b "$COMPARE_FILE"`;
			COMPARE_SIZE=${ORIG_COMPARE_SIZE%%	*};

			((DATA_LIMIT=$FILE_1_SIZE+$FILE_2_SIZE-$COMPARE_SIZE+$ACCEPT_DATA_LIMIT));

			if [ $DATA_LIMIT -le 0 ]; then
				if [[ "$VERBOSITY" == "-v" ]]; then
					echo -e "${CGrn}[Info] Comparing $i $j OK!$CClr";
					echo -e "${CGrn}[Info] Deleting compare files.$CClr";
					echo -e "${CGrn}[Info] Deleting OK!$CClr";
				fi
				rm "$COMPARE_FILE";	
				cd "..";
				continue;
			fi

			if [[ "$VERBOSITY" == "-v" ]]; then
				echo -e "${CGrn}[Info] Stage 3: Checking those files line by line.";
			fi
			
			# Step 3
			FILE_1_DIFFERENT_LINES=`grep ^[-][a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$COMPARE_FILE" | wc -l`;
			FILE_2_DIFFERENT_LINES=`grep ^[+][a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$COMPARE_FILE" | wc -l`;
			((FILE_1_SCORE=$FILE_1_DIFFERENT_LINES*100/FILE_1_LINES));
			((FILE_2_SCORE=$FILE_2_DIFFERENT_LINES*100/FILE_2_LINES));

			if [ $FILE_1_SCORE -ge $REJECT_LINE_SCORE ] || [ $FILE_2_SCORE -ge $REJECT_LINE_SCORE ]; then
				if [[ "$VERBOSITY" == "-v" ]]; then
					echo -e "${CGrn}[Info] Comparing $i $j OK!$CClr";
					echo -e "${CGrn}[Info] Deleting compare files.$CClr";
					echo -e "${CGrn}[Info] Deleting OK!$CClr";
				fi
				rm "$COMPARE_FILE";	
				cd "..";
				continue;
			fi

			if [[ "$VERBOSITY" != "-q" ]]; then
				echo -e "${CYel}[Suspected] Suspected plagiarism detected. Different lines lower than the limit.$CClr";
			fi

			if [[ "$VERBOSITY" == "-v" ]]; then
				echo -e "${CGrn}[Info] Saving file digest to log.$CClr";
				echo -e "${CGrn}[Info] Preserving difference file for further investigation.$CClr";
				echo -e "${CGrn}[Info] Stage 4: Comparing last modified time.$CClr";
			fi

			echo -e "-------- File Digest Separator --------" >> "log.txt";
			echo -e "#1 Filename: $i::File #1 lines: $FILE_1_LINES::Different lines: $FILE_1_DIFFERENT_LINES::Score = $FILE_1_SCORE." >> "log.txt";
			echo -e "#2 Filename: $j::File #2 lines: $FILE_2_LINES::Different lines: $FILE_2_DIFFERENT_LINES::Score = $FILE_2_SCORE." >> "log.txt";
			echo -e "" >> "log.txt";
			
			cd "..";

			# Step 4
			if [[ `find $i -newer $j` == $i ]]; then
				SUMMARY_LINE=$SUMMARY_LINE"\nSuspected/Detected plagiarism: ${CGrn}$j$CClr->${CRed}$i$CClr [$FILE_2_SCORE:$FILE_1_SCORE].";
			else
				SUMMARY_LINE=$SUMMARY_LINE"\nSuspected/Detected plagiarism: ${CGrn}$i$CClr->${CRed}$j$CClr [$FILE_1_SCORE:$FILE_2_SCORE].";
			fi

		fi
	done
done

if [[ "$VERBOSITY" != "-q" ]]; then
	echo -e "Clearing screen ...";
	sleep 3;
fi

clear;
echo -e "$SUMMARY_LINE";
