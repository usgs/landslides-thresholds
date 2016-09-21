#!/bin/sh
cd  ../data/test/ 
# Match slide dates to cumulative precip output
grep -f dates2011Muk.txt ./data/ThArchive02.txt > ./3-15/slides_cum.txt
# Extract and sort 72-hour values
grep -v [a-z] ./data/ThArchive02.txt | awk '{print $5}' | grep -v 99.00 | sort -g > ./3-15/72hour_sort.txt
# Extract and sort AWI hourly values
grep -v [a-z] ./data/ThArchive02.txt | awk '{print $9}' | grep -v 99.00 | sort -g > ./3-15/awi_sort.txt
# For slide dates only, collect data needed to define cumulative distributions
# Extract and sort 72-hour values
grep -v [a-z] ./3-15/slides_cum.txt | awk '{print $5}' | grep -v 99.00 | sort -g > ./3-15/72hour_sort_sl.txt
# Extract and sort AWI hourly values
grep -v [a-z] ./3-15/slides_cum.txt | awk '{print $9}' | grep -v 99.00 | sort -g > ./3-15/awi_sort_sl.txt
# Compute Receiver Operating Characteristics statistics 
../../bin/tsthresh > ./3-15/roc_output.txt
exit
