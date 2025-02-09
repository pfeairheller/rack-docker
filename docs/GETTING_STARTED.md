# Getting Started with RACK
This tutorial will show you how to launch 2 RACK Gateways and configure them to sign and encrypt all data exchanged
between two Mirth Connect integration engine instances.

## Requirements
Docker
Mirth Connect Client

## Steps
Download the docker container healthkeri/rack-mirth-sample:1.0.0 with
docker pull healthkeri/rack-mirth-sample:1.0.0

Mount local directory to /opt/rack/data

Copy the core.cesr files out of the RACK images:
docker cp images-rack-1-1:/opt/rack/data/core.cesr .

DQ7Hzp4faFdbesNx-_a1v