#!/bin/bash

# Usage: ./merge_nrds_days.sh N directory output_file
# N: number of past days to include (excluding today)
# directory: directory where the files are located
# output_file: name of the output file

echo ""

# Check if exactly 3 arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 N directory output_file"
  echo ""
  exit 1
fi

N=$1
directory=$2
output_file=$3
temp_file="$(mktemp)"

# Check if N is a positive integer
if ! [[ "$N" =~ ^[0-9]+$ ]] || [ "$N" -le 0 ]; then
  echo "Error: Please provide a positive integer for the number of days (N)."
  echo ""
  exit 1
fi

# Check if directory exists
if [ ! -d "$directory" ]; then
  echo "Error: Directory not found: $directory"
  echo ""
  exit 1
fi

today=$(date +%F)
> "$temp_file"

echo "Including NRD files:"
echo ""

# Loop over the last N days, excluding today
for ((i=1; i<=N; i++)); do
  current_date=$(date -d "$today - $i days" +%F)
  file_path="$directory/nrds_${current_date}.txt"

  if [[ -f "$file_path" ]]; then
    echo "  $file_path - $(wc -l < $file_path) NRDs"
    cat "$file_path" >> "$temp_file"
  else
    echo "  $file_path - 0 NRDs"
  fi
done

sort -u "$temp_file" > "$output_file"
rm "$temp_file"

line_count=$(wc -l < "$output_file")

echo ""
echo "Total unique NRDs in $output_file: $line_count"
echo ""
