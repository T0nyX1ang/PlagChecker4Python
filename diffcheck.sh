#!/bin/bash

WORKING_DIR=".";
TESTING_DIR="COMPARE_TESTS";
ACCEPT_DATA_LIMIT=300;
REJECT_LINE_SCORE=70;

# Define colors
readonly CRed="\e[0;31m"
readonly CGrn="\e[0;32m"
readonly CYel="\e[0;33m"
readonly CClr="\e[0m"

SUMMARY_LINE="Summary of files: ";

# Check if testing directory exists.
if [[ ! -d "$TESTING_DIR" ]]; then
	echo -e "${CGrn}[Info] Creating testing directory.$CClr";
	mkdir $TESTING_DIR;
fi

# Check if working and testing directory writable.
if [[ ! -w "$TESTING_DIR" ]] || [[ ! -w "$WORKING_DIR" ]]; then
	# Output an error if permission denied.
	echo -e "${CRed}[Error] Permission Denied! Check your permission first.$CClr";
	exit;
fi

if [[ -f "$TESTING_DIR/log.txt" ]]; then
	echo -e "${CGrn}[Info] Deleting existing log file.$CClr";
	rm "$TESTING_DIR/log.txt";
fi

for i in `ls -1 | grep .py$ `; do
	for j in `ls -1 | grep .py$ `; do
		if [[ "$i" < "$j" ]] && [[ "$i" != "diffcheck.sh" ]] && [[ "$j" != "diffcheck.sh" ]] && [[ "$i" != "$TESTING_DIR" ]] && [[ "$j" != "$TESTING_DIR" ]]; then
			COMPARE_FILE="$i""_COMPARE_""$j"".txt";

			echo -e "${CGrn}[Info] Evaluating file sizes of $i.$CClr";
			ORIG_FILE_1_SIZE=`du -h -b "$i"`;
			FILE_1_SIZE=${ORIG_FILE_1_SIZE%%	*};

			echo -e "${CGrn}[Info] Evaluating file lines of $i.$CClr";
			FILE_1_LINES=`grep ^[a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$i" | wc -l`;
			
			echo -e "${CGrn}[Info] Evaluating file sizes of $j.$CClr";
			ORIG_FILE_2_SIZE=`du -h -b "$j"`;
			FILE_2_SIZE=${ORIG_FILE_2_SIZE%%	*};

			echo -e "${CGrn}[Info] Evaluating file lines of $j.$CClr";
			FILE_2_LINES=`grep ^[a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$j" | wc -l`;
			
			echo -e "${CGrn}[Info] Comparing $i and $j.$CClr";
			cd "$TESTING_DIR";
			# Suppressing all white spaces(-w), blank lines(-B), sensitive cases(-i) and annotations(-I '^#').
			# Making an unified 'diff' output here.
			diff -w -B -i -I '^#' -u "../""$i" "../""$j" > "$COMPARE_FILE";
			
			echo -e "${CGrn}[Info] Stage 1: Checking if two files are identical.$CClr";

			if [[ ! -s "$COMPARE_FILE" ]]; then
				echo -e "${CRed}[Detected] Plagiarism detected. Identical files found!$CClr";
				echo -e "${CGrn}[Info] Saving file digest to log.$CClr";
				echo -e "Plagiarism detected. Identical files found!" >> "log.txt";
				echo -e "-------- File Digest Separator --------" >> "log.txt";
				echo -e "#1 Filename: $i::File #1 lines: $FILE_1_LINES::Different lines: 0::Score = 0." >> "log.txt";
				echo -e "#2 Filename: $j::File #2 lines: $FILE_2_LINES::Different lines: 0::Score = 0." >> "log.txt";
				echo -e "" >> "log.txt";
				cd "..";
				continue;
			fi
			
			echo -e "${CGrn}[Info] Stage 2: Checking if the difference of those files are above limit.$CClr";

			ORIG_COMPARE_SIZE=`du -h -b "$COMPARE_FILE"`;
			COMPARE_SIZE=${ORIG_COMPARE_SIZE%%	*};

			((DATA_LIMIT=$FILE_1_SIZE+$FILE_2_SIZE-$COMPARE_SIZE+$ACCEPT_DATA_LIMIT));

			if [ $DATA_LIMIT -le 0 ]; then
				echo -e "${CGrn}[Info] Comparing $i $j OK!$CClr";
				echo -e "${CGrn}[Info] Deleting compare files.$CClr";
				rm "$COMPARE_FILE";
				echo -e "${CGrn}[Info] Deleting OK!$CClr";
				cd "..";
				continue;
			fi

			echo -e "${CGrn}[Info] Stage 3: Checking those files line by line.";
			FILE_1_DIFFERENT_LINES=`grep ^[-][a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$COMPARE_FILE" | wc -l`;
			FILE_2_DIFFERENT_LINES=`grep ^[+][a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$COMPARE_FILE" | wc -l`;
			((FILE_1_SCORE=$FILE_1_DIFFERENT_LINES*100/FILE_1_LINES));
			((FILE_2_SCORE=$FILE_2_DIFFERENT_LINES*100/FILE_2_LINES));

			if [ $FILE_1_SCORE -ge $REJECT_LINE_SCORE ] || [ $FILE_2_SCORE -ge $REJECT_LINE_SCORE ]; then
				echo -e "${CGrn}[Info] Comparing $i $j OK!$CClr";
				echo -e "${CGrn}[Info] Deleting compare files.$CClr";
				rm "$COMPARE_FILE";
				echo -e "${CGrn}[Info] Deleting OK!$CClr";
				cd "..";
				continue;
			fi

			echo -e "${CYel}[Suspected] Suspected plagiarism detected. Different lines lower than the limit.$CClr";
			echo -e "${CGrn}[Info] Saving file digest to log.$CClr";
			echo -e "-------- File Digest Separator --------" >> "log.txt";
			echo -e "#1 Filename: $i::File #1 lines: $FILE_1_LINES::Different lines: $FILE_1_DIFFERENT_LINES::Score = $FILE_1_SCORE." >> "log.txt";
			echo -e "#2 Filename: $j::File #2 lines: $FILE_2_LINES::Different lines: $FILE_2_DIFFERENT_LINES::Score = $FILE_2_SCORE." >> "log.txt";
			echo -e "" >> "log.txt";
			echo -e "${CGrn}[Info] Preserving difference file for further investigation.$CClr";

			cd "..";

			echo -e "${CGrn}[Info] Stage 4: Comparing last modified time.$CClr";
			if [[ `find $i -newer $j` == $i ]]; then
				SUMMARY_LINE=$SUMMARY_LINE"\nSuspected/Detected plagiarism: ${CGrn}$j$CClr->${CRed}$i$CClr [$FILE_2_SCORE:$FILE_1_SCORE].";
			else
				SUMMARY_LINE=$SUMMARY_LINE"\nSuspected/Detected plagiarism: ${CGrn}$i$CClr->${CRed}$j$CClr [$FILE_1_SCORE:$FILE_2_SCORE].";
			fi

		fi
	done
done

echo -e "Clearing screen ...";
sleep 3;
clear;
echo -e "$SUMMARY_LINE";
