WORKING_DIR=".";
TESTING_DIR="COMPARE_TESTS";
ACCEPT_DATA_LIMIT=300;
REJECT_LINE_SCORE=80;

# Check if testing directory exists.
if [[ ! -d "$TESTING_DIR" ]]; then
	mkdir $TESTING_DIR;
fi

# Check if working and testing directory writable.
if [[ ! -w "$TESTING_DIR" ]] || [[ ! -w "$WORKING_DIR" ]]; then
	# Output an error if permission denied.
	echo "[Error] Permission Denied! Check your permission first.";
	exit;
fi

if [[ -f "$TESTING_DIR/log.txt" ]]; then
	rm "$TESTING_DIR/log.txt";
fi

for i in `ls -1 | grep .py$ `; do
	for j in `ls -1 | grep .py$ `; do
		if [[ "$i" < "$j" ]] && [[ "$i" != "diffcheck.sh" ]] && [[ "$j" != "diffcheck.sh" ]] && [[ "$i" != "$TESTING_DIR" ]] && [[ "$j" != "$TESTING_DIR" ]]; then
			COMPARE_FILE="$i""_COMPARE_""$j"".txt";

			echo "[Info] Evaluating file sizes of $i.";
			ORIG_FILE_1_SIZE=`du -h -b "$i"`;
			FILE_1_SIZE=${ORIG_FILE_1_SIZE%%	*};

			echo "[Info] Evaluating file lines of $i.";
			FILE_1_LINES=`grep ^[a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$i" | wc -l`;
			
			echo "[Info] Evaluating file sizes of $j.";
			ORIG_FILE_2_SIZE=`du -h -b "$j"`;
			FILE_2_SIZE=${ORIG_FILE_2_SIZE%%	*};

			echo "[Info] Evaluating file lines of $j."
			FILE_2_LINES=`grep ^[a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$j" | wc -l`;
			
			echo "[Info] Comparing $i and $j.";
			cd "$TESTING_DIR";
			# Suppressing all white spaces(-w), blank lines(-B), sensitive cases(-i) and annotations(-I '^#').
			# Making an unified 'diff' output here.
			diff -w -B -i -I '^#' -u "../""$i" "../""$j" > "$COMPARE_FILE";
			
			echo "[Info] Stage 1: Checking if two files are identical.";

			if [[ ! -s "$COMPARE_FILE" ]]; then
				echo "[Info] Plagiarism detected. Identical files found!";
				echo "[Info] Plagiarism detected. Identical files found!" >> "log.txt";
				cd "..";
				continue;
			fi
			
			echo "[Info] Stage 2: Checking if the difference of those files are above limit.";

			ORIG_COMPARE_SIZE=`du -h -b "$COMPARE_FILE"`;
			COMPARE_SIZE=${ORIG_COMPARE_SIZE%%	*};

			((DATA_LIMIT=$FILE_1_SIZE+$FILE_2_SIZE-$COMPARE_SIZE+$ACCEPT_DATA_LIMIT));

			if [ $DATA_LIMIT -le 0 ]; then
				echo "[Info] Comparing $i $j OK!";
				echo "[Info] Deleting compare files.";
				rm "$COMPARE_FILE";
				echo "[Info] Deleting OK!";
				cd "..";
				continue;
			fi

			echo "[Info] Stage 3: Checking those files line by line.";
			FILE_1_DIFFERENT_LINES=`grep ^[-][a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$COMPARE_FILE" | wc -l`;
			FILE_2_DIFFERENT_LINES=`grep ^[+][a-zA-Z0-P_=" "\*\&\(\)\$"	"] "$COMPARE_FILE" | wc -l`;
			((FILE_1_SCORE=$FILE_1_DIFFERENT_LINES*100/FILE_1_LINES));
			((FILE_2_SCORE=$FILE_2_DIFFERENT_LINES*100/FILE_2_LINES));

			if [ $FILE_1_SCORE -ge $REJECT_LINE_SCORE ] || [ $FILE_2_SCORE -ge $REJECT_LINE_SCORE ]; then
				echo "[Info] Comparing $i $j OK!";
				echo "[Info] Deleting compare files.";
				rm "$COMPARE_FILE";
				echo "[Info] Deleting OK!";
				cd "..";
				continue;
			fi

			echo "[Info] Suspected plagiarism detected. Different lines lower than the limit.";
			echo "[Info] Saving file digest to log.";
			echo "-------- File Digest Separator --------" >> "log.txt";
			echo "#1 Filename: $i::File #1 lines: $FILE_1_LINES::Different lines: $FILE_1_DIFFERENT_LINES::Score = $FILE_1_SCORE." >> "log.txt";
			echo "#2 Filename: $j::File #2 lines: $FILE_2_LINES::Different lines: $FILE_2_DIFFERENT_LINES::Score = $FILE_2_SCORE." >> "log.txt";
			echo "" >> "log.txt";
			echo "[Info] Preserving difference file for further investigation.";
			
			#sleep 2;

			cd "..";
		fi
	done
done

