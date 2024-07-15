#!/bin/bash

# Extract all files in a folder as single txt file
# Usage: ./extract_folder_as_txt.sh folder_name output_file.txt
#
# Example: ./extract_folder_as_txt.sh folder1 output.txt
#
# This will extract all files in folder1 as output.txt
# If output.txt already exists, it will be overwritten
# If output.txt does not exist, it will be created
# If folder1 does not exist, it will throw an error
# If folder1 is empty, output.txt will be empty

# Function to parse sops.yaml and return a grep pattern
parse_sops_yaml() {
    local sops_file="$1/.sops.yaml"
    if [ -f "$sops_file" ]; then
        # Extract paths from sops.yaml and convert them to a grep pattern
        local pattern=$(grep "path_regex:" "$sops_file" | sed -E 's/.*path_regex: *(.*)$/\1/' | tr '\n' '|' | sed 's/|$//')
        if [ -n "$pattern" ]; then
            echo "-E -v '($pattern|\\.git|\\.DS_Store|flake.lock)'"
        else
            echo "-E -v '(\\.git|\\.DS_Store|flake.lock)'"
        fi
    else
        echo "-E -v '(\\.git|\\.DS_Store|flake.lock)'"
    fi
}

# Check if the number of arguments is correct
if [ "$#" -ne 2 ]; then
    echo "Usage: ./extract_folder_as_txt.sh folder_name output_file.txt"
    exit 1
fi

# Check if the folder exists
if [ ! -d "$1" ]; then
    echo "Error: Folder $1 does not exist"
    exit 1
fi

# Get grep pattern based on sops.yaml
grep_pattern=$(parse_sops_yaml "$1")

# Get list of files in the folder, excluding patterns from sops.yaml, .git and .DS_Store
files=$(find "$1" -type f -name '*' | eval grep $grep_pattern | sort)

# Create or truncate the output file
rm "$2" 2>/dev/null
touch "$2"

# Check if we have permission to write to the output file
if [ ! -w "$2" ]; then
    echo "Error: Cannot write to $2"
    exit 1
fi

# Loop through each file and append to the output file
for file in $files; do
    if [ -r "$file" ]; then
        echo "--- $file:" >> "$2"
        # Use sed to filter out lines containing 'boot.loader'
        sed 's/boot\.loader//g' "$file" | sed 's/boot//g' >> "$2"
    else
        echo "Warning: Cannot read $file. Skipping."
    fi
done

echo "Extraction complete. Output written to $2"
