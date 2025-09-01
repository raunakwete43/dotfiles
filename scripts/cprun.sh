#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <cpp_file>"
  exit 1
fi

cpp_file=$1
output_file="${cpp_file%.cpp}"

# Compile the C++ program
g++ "$cpp_file" -o "$output_file"

if [ $? -eq 0 ]; then
  # Run the compiled program if compilation is successful
  "./$output_file"
else
  echo "Compilation failed."
fi

