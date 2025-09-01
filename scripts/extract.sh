#!/bin/bash

# Function to extract compressed files into a new folder
extract_file() {
    file=$1
    folder="${file%%.*}"
    case $file in
        *.zip)     unzip -d "$folder" "$file" ;;
        *.tar)     mkdir -p "$folder" && tar -xvf "$file" -C "$folder" ;;
        *.tar.gz)  mkdir -p "$folder" && tar -xzvf "$file" -C "$folder" ;;
        *.tgz)     mkdir -p "$folder" && tar -xzvf "$file" -C "$folder" ;;
        *.tar.xz)  mkdir -p "$folder" && tar -xJvf "$file" -C "$folder" ;;
        *.tar.bz2) mkdir -p "$folder" && tar -xjvf "$file" -C "$folder" ;;
        *.gz)      gunzip -d "$file" ;;
        *.7z)      7z x "$file" -o"$folder" ;;
        *)         echo "Unsupported file type: $file" ;;
    esac
}

# Check if at least one argument is provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 file1 [file2 ...]"
    exit 1
fi

# Loop through each provided file and extract it
for file in "$@"; do
    if [ -f "$file" ]; then
        echo "Extracting $file into a new folder..."
        extract_file "$file"
    else
        echo "File not found: $file"
    fi
done

echo "Extraction completed."

