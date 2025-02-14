# Getting Started with RACK
This tutorial will show you how to launch 2 RACK Gateways and configure them to sign and encrypt all data exchanged
between two Mirth Connect integration engine instances.

## Requirements
Docker
Mirth Connect Client

## Steps

- Download the RACK wheel from XXX
- Create new python venv with Python 3.12.8 `python -m venv ./rack`
- Install RACK Python library with `pip install rack-1.0.0-py3-none-any.whl`
- Install 2 instances of RACK:
    - `rack install --name Mirth1 --salt Bd8VBggWxGP-OjI7R4vxM --passid-file ./passid.cesr --admin-port 17632`
    - `rack install --name Mirth2 --salt DYA2LrpDmnk1xgI4ADxbc --passid-file ./passid.cesr`
- In two seperate windows launch an instance of RACK with the names used above
    - `rack start --name Mirth1`
    - `rack start --name Mirth2 --metrics-port 9002`
- Launch Locksmith
- Create a new vault called "Locksmith"
- Open the "Locksmith" vault
- Create an Identifier named `admin` using the salt `DQ7Hzp4faFdbesNx-_a1v`
    - Ensure the AID is "EK4iFDRWMPH2mJ_VSJZt5VgCTg7wupzKX5nipreSOBuR" 
- Create a Remote Identifier called "Outbound" using the file "Outbound-core.cesr" create during the first install of RACK 
    - Ensure the AID is "EPIa-VqM9y2EUUMAJ0MAv5AEdDVvaOcFmIxKn5jzIgKk" 
- Create a Remote Identifier called "Inbound" using the file "Inbound-core.cesr" create during the first install of RACK 
    - Ensure the AID is "EJ8Rx6lal6S7mlrhp6OuHkxAizP7N5ufzllu4YIbjjvV" 
- Create a new proxy, for Local AID, choose `admin` and for Remote AID choose `Outbound`.  Ensure that port 15632 shows up as the port
- Create a new proxy, for Local AID, choose `admin` and for Remote AID choose `Inbound`.  Ensure that port 17632 shows up as the port
- Using the context menu for each Proxy, Launch the proxy.  a RACK Adminstration console web tab should open for each RACK gateway.


Download the docker container healthkeri/rack-mirth-sample:1.0.0 with
docker pull healthkeri/rack-mirth-sample:1.0.0

Mount local directory to /opt/rack/data

Copy the core.cesr files out of the RACK images:
docker cp images-rack-1-1:/opt/rack/data/core.cesr .

