#!/usr/bin/env bash


# Run the vnstat command and capture the output
vnstat_output=$(vnstat -d)

# Use awk to extract the total data used from the specific row and column
# Assuming the data is always in the 4th row and 7th and 8th columns
total_data_used=$(echo "$vnstat_output" | awk 'NR==6 {print $8 " "}')

total_data_used_mb=$(echo "$total_data_used * 1.048576 / 1" | bc)

# Print the total data used
echo " $total_data_used_mb MB"
