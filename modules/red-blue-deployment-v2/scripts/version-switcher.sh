#!/usr/bin/env bash

# This script uses 3 variables to track the commit hashes of releases and map
# them to GAE service versions. They are `red`, `blue`, and `current`. We use
# files and GCS objects with the same names to persist their values to following
# build steps, specifically Terragrunt. This allows the infrastructure state to
# be declaratively applied.

# `red` and `blue` keep the commit hashes of the currently applied GAE service
# versions. `current` keeps the name of the currently active version, either the
# strings "red" or "blue". This script takes the new hash, `$COMMIT_SHA`, and
# saves it to the non-current version. It then changes the value in the current
# file to point to the new version name.

# Main ########################################################################

# Fetch the state files from the bucket and store in variables.
red=`gsutil cat $COMPONENT_URL/red`
blue=`gsutil cat $COMPONENT_URL/blue`
current=`gsutil cat $COMPONENT_URL/current`

echo "Initial Values"
echo "red:     $red"
echo "blue:    $blue"
echo "current: $current"

# Update the hash and switch current version.
if [ "$current" == "red" ]; then
    # Replace the other version with the new commit SHA.
    blue=$COMMIT_SHA
    # Make blue the new current.
    current=blue
else
    # Replace the other version with the new commit SHA.
    red=$COMMIT_SHA
    # Make red the new current.
    current=red
fi

echo "Switched Values"
echo "red:     $red"
echo "blue:    $blue"
echo "current: $current"

# Save values to local files.
echo -n $red > red
echo -n $blue > blue
echo -n $current > current

# Upload the local files to bucket.
for FILENAME in red blue current
do
    gsutil cp $FILENAME $COMPONENT_URL/$FILENAME
done
