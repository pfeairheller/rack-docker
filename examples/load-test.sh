#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <src> <number_of_files>"
  exit 1
fi

# Dataset to search for files
DATASET="$1"
# Number of files to process
NUM_FILES="$2"

# Check if the number of files is a valid number
if ! [[ "$NUM_FILES" =~ ^[0-9]+$ ]]; then
  echo "The number of files must be a positive integer."
  exit 1
fi


case "$DATASET" in
  "fhir-dataset"|"fhir-dataset-large")
    echo "Copying ${NUM_FILES} file(s) from ${DATASET} to Mirth1 data directory"
    ;;
  *)  # Optional: Handle other cases
    echo "<src> must be one of 'fhir-dataset' or 'fhir-dataset-large"
    exit 1
    ;;
esac

# Directory to search for files
SRC="./data/${DATASET}"
DEST="./data/volumes/mirth1"

# Check if the directory exists
if [[ ! -d "$SRC" ]]; then
  echo "Directory $SRC does not exist."
  exit 1
fi

# Get a list of random files from the directory
FILES=$(ls "$SRC" | shuf -n "$NUM_FILES")

# Loop over each file and perform an action
for FILE in $FILES; do
  size=$(ls -lh "${SRC}/${FILE}" | awk '{print $5}')
  echo -n "Sending $FILE - $size "
  cp "${SRC}/${FILE}" "${DEST}"
  echo ""
done
