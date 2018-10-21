WORKING_DIR=".";
TESTING_DIR="COMPARE_TESTS";

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
			cd "$TESTING_DIR";
			# Suppressing all white spaces(-w), blank lines(-B), sensitive cases(-i) and annotations(-I '^#').
			# Making an unified 'diff' output here.
			diff -w -B -i -I '^#' -u "../""$i" "../""$j" > "$COMPARE_FILE";
			echo "[Info] Stage 1: Checking if two files are identical."
			if [[ ! -s "$COMPARE_FILE" ]]; then
				echo "[Info] Plagiarism detected. Identical files found!";
			fi
			cd "..";
			echo "[Info] Compare $i $j OK!"
		fi
	done
done
