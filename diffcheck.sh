# Check if working directory exists.
if [ ! -d "COMPARE_TESTS" ]; then
	mkdir COMPARE_TESTS;
fi

# Check if working directory writable. (Later development)

for i in `ls -1`; do
	for j in `ls -1`; do
		if [ "$i" != "$j" ] && [ "$i" != "diffcheck.sh" ] && [ "$j" != "diffcheck.sh" ] && [ "$i" != "COMPARE_TESTS" ] && [ "$j" != "COMPARE_TESTS" ]; then
			s="$i""_COMPARE_""$j"".txt"; 
			d="COMPARE_TESTS"
			cd "$d";
			diff -C 0 -aiEZbwBIy "../""$i" "../""$j" > "$s";
			cd "..";
			echo "[compare] $i $j OK!"
		fi
	done
done
