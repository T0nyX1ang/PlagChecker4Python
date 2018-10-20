mkdir COMPARE_TESTS;
for i in `ls -1`; do
	for j in `ls -1`; do
		if [ "$i" != "$j" ] && [ "$i" != "diffcheck.sh" ] && [ "$j" != "diffcheck.sh" ] && [ "$i" != "COMPARE_TESTS" ] && [ "$j" != "COMPARE_TESTS" ]; then
			s="$i""_COMPARE_""$j"".txt"; 
			d="COMPARE_TESTS"
			cd "$d";
			diff -aicEZbwBIy "../""$i" "../""$j" > "$s";
			cd "..";
			echo "[compare] $i $j OK!"
		fi
	done
done