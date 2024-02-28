#!/usr/bin/env bash

# create a stack of SHAs of the recent deploys.
# check new sha to see if it's at the start of the file
# if not take the last 4 lines and save them over the file.
# then append the new hash to the front of the file.

# when getting the deployment state the first line is the current version. the
# following are the older versions.

# Main ########################################################################

FILENAME=version_hashes

# load in file
gsutil cp $COMPONENT_URL/$FILENAME $FILENAME

# Trim newline from hash.
CURRENT=$(head -n 1 $FILENAME | tr -d '\n')

# If the new hash is the same as the current, exit.
if [ "$COMMIT_SHA" = "$CURRENT" ]; then
    echo "New commit hash: $COMMIT_SHA is the same as the current hash. Exiting."
    exit 0
fi

# Add new hash to head of file
echo "$(echo $COMMIT_SHA; head -n 4 $FILENAME)" > $FILENAME

# Only save the first 5 hashes.
head -n 5 $FILENAME > tmp
mv tmp $FILENAME

echo "Commit hash: $COMMIT_SHA is now the current version."
cat $FILENAME
