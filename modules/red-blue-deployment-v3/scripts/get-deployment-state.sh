#!/bin/bash

# Initialize state files if they don't exist.
for FILENAME in red blue current
do
    FILE_URL=$COMPONENT_URL/$FILENAME

    gsutil -q stat $FILE_URL
    STATUS=$?

    # gsutil stat command returns status 1 if the file is not found. 0 if the
    # file is found.
    if [ $STATUS == 1 ]; then
        # Create an empty local file to upload.
        echo -n "initial" > $FILENAME

        if [ $FILENAME == "current" ]; then
            echo -n "blue" > $FILENAME
        fi

        # Copy the file to the archive bucket.
        gsutil cp $FILENAME $FILE_URL

        # Remove the local file.
        rm $FILENAME
    fi
done

# Fetch the state files from the bucket and store in variables.
red=`gsutil cat $COMPONENT_URL/red`
blue=`gsutil cat $COMPONENT_URL/blue`
current=`gsutil cat $COMPONENT_URL/current`

printf '{"red":"%s","blue":"%s","current":"%s"}\n' "$red" "$blue" "$current"
