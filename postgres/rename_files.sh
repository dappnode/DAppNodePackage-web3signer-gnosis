#!/bin/sh

# Loop over each file in the /docker-entrypoint-initdb.d directory
for file in ${INITDB_DIR}*; do
    # Extract the base name and directory of the file
    dir=$(dirname "$file")
    base=$(basename "$file")

    # Use sed to modify the file name
    # This will pad the first number in the file name with zeros to make it three digits long
    new_base=$(echo "$base" | sed -r 's/([0-9]+)/000\1/g; s/0*([0-9]{3})/\1/g')

    # Move (rename) the file to its new name
    mv "$dir/$base" "$dir/$new_base"
done
