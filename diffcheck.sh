WORKING_DIR=".";
TESTING_DIR="COMPARE_TESTS";
ACCEPT_DATA_LIMIT=6500;
REJECT_LINE_LIMIT=50;

# Check if testing directory exists.
if [[ ! -d "$TESTING_DIR" ]]; then
	mkdir COMPARE_TESTS;
fi

# Check if working and testing directory writable.
if [[ ! -w "$TESTING_DIR" ]] || [[ ! -w "$WORKING_DIR" ]]; then
	# Output an error if permission denied.
	echo "[Error] Permission Denied! Check your permission first.";
	exit;
fi

for i in `ls -1`; do
	for j in `ls -1`; do
		if [[ "$i" < "$j" ]] && [[ "$i" != "diffcheck.sh" ]] && [[ "$j" != "diffcheck.sh" ]] && [[ "$i" != "$TESTING_DIR" ]] && [[ "$j" != "$TESTING_DIR" ]]; then
			COMPARE_FILE="$i""_COMPARE_""$j"".txt";

			echo "[Info] Evaluating file sizes of $i.";
			ORIG_FILE_1_SIZE=`du -h -b "$i"`;
			FILE_1_SIZE=${ORIG_FILE_1_SIZE%%	*};
			
			echo "[Info] Evaluating file sizes of $i.";
			ORIG_FILE_2_SIZE=`du -h -b "$j"`;
			FILE_2_SIZE=${ORIG_FILE_2_SIZE%%	*};
			
			echo "[Info] Comparing $i and $j.";
			cd "$TESTING_DIR";
			# Suppressing all white spaces(-w), blank lines(-B), sensitive cases(-i) and annotations(-I '^#').
			# Making an unified 'diff' output here.
			diff -w -B -i -I '^#' -u "../""$i" "../""$j" > "$COMPARE_FILE";
			
			echo "[Info] Stage 1: Checking if two files are identical.";

			if [[ ! -s "$COMPARE_FILE" ]]; then
				echo "[Info] Plagiarism detected. Identical files found!";
				cd "..";
				continue;
			fi
			
			echo "[Info] Stage 2: Checking if the difference of those files are above limit.";

			ORIG_COMPARE_SIZE=`du -h -b "$COMPARE_FILE"`;
			COMPARE_SIZE=${ORIG_COMPARE_SIZE%%	*};

			if [ $COMPARE_SIZE -ge $ACCEPT_DATA_LIMIT ]; then
				echo "[Info] Comparing $i $j OK!";
				echo "[Info] Deleting compare files.";
				rm "$COMPARE_FILE";
				echo "[Info] Deleting OK!";
				cd "..";
				continue;
			fi
			
			cd "..";
		fi
	done
done
