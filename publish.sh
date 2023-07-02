#!/bin/bash

echo "Define the temporary directory path"
temp_dir="temp"

echo "Create the temporary directory if it doesn't exist"
if [ ! -d "$temp_dir" ]; then
  mkdir "$temp_dir"
fi

echo "Create a temporary exclude file"
exclude_file=$(mktemp)

echo "$temp_dir" >> "$exclude_file"

echo "Read .gitignore and generate exclude patterns"
while IFS= read -r pattern; do
  if [[ ! $pattern =~ ^# && $pattern != "" ]]; then
    echo "$pattern" >> "$exclude_file"
  fi
done < .gitignore

echo "Find all files and directories excluding those in .gitignore"
rsync -av --exclude-from="$exclude_file" --relative ./ "$temp_dir"

echo "Set the zip directory to the current directory"
zip_dir="."

echo "Zip the contents of the temporary directory to the zip directory"
(cd "$temp_dir" && zip -r dist.zip ./*)

echo "Move the zip archive to the current directory"
mv -f "$temp_dir/dist.zip" "$zip_dir/dist.zip"

echo "Clean up the temporary directory and exclude file"
rm -rf "$temp_dir"
rm "$exclude_file"

echo "Zip archive created: $zip_dir/dist.zip"
