#!/bin/bash

# check command line parameters
if [ $# -ne 2 ]; then
        echo "Counts the entropy of each file in the given folder and writes the results to a csv file."
        echo "Usage: $0 <target folder> </path/to/results.csv>"
        exit 1
fi

# assign variables
dir="$1"
result1="tmp-results1"
result2="tmp-results2"
resultsfile="$2"

#count the entropy
find $dir -exec echo {} \; -exec ent {} \; >>  $result1
grep Entropy $result1 -B 1 >> $result2

sed -i 's/Entropy = //' $result2
sed -i 's/ bits per byte.//' $result2
sed -i ':a;N;$!ba;s/\n/;/g' $result2
sed -i 's/--;/\n/g' $result2

# copy results to intended path and remove temporary files
mv $result2 $results
rm $result1

exit 0
