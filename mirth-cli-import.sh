#!/bin/bash

if [ -z "${MIRTH_HOST+x}" ]; then
  export MIRTH_HOST=8632
fi

if [ -z "${MIRTH_PORT+x}" ]; then
  export  MIRTH_PORT=8632
fi

# Function to wait for Mirth Connect to be ready (improve as needed)
wait_for_mirth() {
  while true; do
    # Check if Mirth is ready (replace with a more robust check if possible)
    curl --insecure -s "https://${MIRTH_HOST}:${MIRTH_PORT}/api/server/status" > /dev/null 2>&1  # Suppress output
    if [[ $? -eq 0 ]]; then # Check the exit code of curl. 0 means success.
      return
    fi
    echo "Mirth Connect not yet ready at ${MIRTH_HOST}:${MIRTH_PORT}. Retrying..."
    sleep 5
  done
}

# Wait for Mirth to be ready
wait_for_mirth
# Loop through channel files and import them
for channel_file in /opt/connect/channels/*.xml; do
  echo "Importing channel: $channel_file"
cat << EOF > /opt/connect/channels/script.txt
import "${channel_file}"
deploy
channel enable *
channel start *
EOF
  /opt/connect/cli/mccommand -u admin -p admin -a "https://${MIRTH_HOST}:${MIRTH_PORT}" -s "/opt/connect/channels/script.txt"
  if [[ $? -ne 0 ]]; then
    echo "Error importing channel: $channel_file"
    exit 1  # Exit the script if there's an error
  fi
done