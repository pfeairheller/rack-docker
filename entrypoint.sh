#!/bin/bash
set -e

if [ -z "${RACK_NAME+x}" ]; then
  export RACK_NAME="Rack"
fi

if [ -z "${PORT+x}" ]; then
  export PORT=8632
fi

if [[ -z "${SALT+x}" || -z "${PASS_ID+x}" ]]; then
  ARGS="--insecure"
else
  ARGS="--salt ${SALT} --passid-file ${PASS_ID}"
fi

if [ -n "${PASSCODE+x}" ]; then
  ARGS="${ARGS} --passcode ${PASSCODE}"
fi

# Check for one-time installation per running container
if [ ! -f /opt/rack/initialized ]; then
  . "${VIRTUAL_ENV}/bin/activate" && \
      rack install --name "${RACK_NAME}" ${ARGS} --admin-port "${PORT}" --admin-host "0.0.0.0"
  touch /opt/rack/initialized # Create a file to mark initialization
fi

# Start your main application
exec "$@"