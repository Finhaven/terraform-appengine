#!/bin/sh

# Initialize state file if they don't exist.
FILENAME=version_hashes
FILE_URL=$COMPONENT_URL/$FILENAME

# gsutil -q stat $FILE_URL
# STATUS=$?

# # gsutil stat command returns status 1 if the file is not found. 0 if the file
# # is found.
# if [ $STATUS -eq 1 ]; then
#     # Create an empty local file to upload.
#     touch $FILENAME
#     echo "initial" > $FILENAME

#     # Copy the file to the archive bucket.
#     gsutil cp $FILENAME $FILE_URL

#     # Remove the local file.
#     rm $FILENAME
# fi


# # get the file with the hashes in it.
# gsutil cp $FILE_URL $FILENAME

# ensure we are only using the first 5 version hashes
head -n 5 $FILENAME > tmp
mv tmp $FILENAME

printf '[\n'
i=1
len=`cat $FILENAME | wc -l`
for hash in `cat $FILENAME`
do
    # Trim newline from hash.
    tmp=`echo $hash | tr -d '\n'`
    # Add hash to JSON output.
    printf '  "%s"' $tmp
    # Add list separator if not the last element.
    if [ "$i" -lt "$len" ]; then
        printf ',\n'
    fi
    i=$((i+1))
done
printf '\n]\n'
