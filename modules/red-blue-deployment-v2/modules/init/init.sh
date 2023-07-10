#!/bin/bash

echo "Initializing deployment state files at:"
echo $COMPONENT_URL

# Initialize state files if they don't exist.
for FILENAME in red blue current
do
    FILE_URL=$COMPONENT_URL/$FILENAME
    gsutil -q stat $FILE_URL
    STATUS=$?

    # gsutil stat command returns status 1 if the file is not found. 0 if the
    # file is found.
    if [[ $STATUS == 1 ]]; then
        # Create an empty local file to upload.
        touch $FILENAME

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

echo "Initial Values"
echo "red:     $red"
echo "blue:    $blue"
echo "current: $current"
