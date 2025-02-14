# Getting Started with RACK
This tutorial will show you how to launch two RACK Gateways and configure them to sign and encrypt all data exchanged
between two Mirth Connect integration engine instances. 

<a name="top"></a>
## Table of Contents

* [Requirements](#requirements)
* [What is Mirth Connect?](#what-is-mirth-connect)
* [Is Mirth Connect Secure On Its Own?](#is-mirth-connect-secure-on-its-own)
* [Securing Data Exchange with RACK and Locksmith](#securing-data-exchange-with-rack-and-locksmith)
* [Tutorial Overview](#tutorial-overview)
* [Setup Mirth Images Via Docker Compase](#setup-mirth-images-via-docker-compose)
* [Setup and Install RACK Locally](#setup-and-install-rack-locally)
* [Start Local RACK Gateways](#start-local-rack-gateways)
* [Install Locksmith and Setup Proxies](#install-locksmith-and-setup-proxies)
* [Connect Mirth Instances with RACK Admin Via Locksmith](#connect-mirth-instances-with-rack-admin-via-locksmith)
* [License](#license)

------------
<a name="requirements"></a>
## Requirements [↑](#top)
- Docker Compose
- Locksmith

<a name="what-is-mirth-connect"></a>
## What is Mirth Connect? [↑](#top)
Mirth Connect is an open-source integration engine designed for data exchange in the healthcare industry. It enables 
communication between disparate information systems by supporting various healthcare data exchange standards, namely, HL7 and FHIR 
for text based patient health information, and DICOM for medical imaging transfer. Mirth Connect is intended to 
facilitate the routing, transformation, and filtering of clinical data between different healthcare sectors and their 
associated information systems. It is used to integrate data from hospitals, clinics, imaging centers, 
laboratories, and pharmacies, and more. For the purposes of this tutorial, Mirth Connect serves as a stand-in for any
given integration engine used in the HealthCare sector. 

Check out their [github repo](https://github.com/nextgenhealthcare/connect)

<a name="is-mirth-connect-secure-on-its-own"></a>
## Is Mirth Connect Secure On Its Own? [↑](#top)
The short answer is no. To be clear, this is not an explicit fault of mirth, rather it is fault of modern data exchange 
cybersecurity practices as a whole. Mirth offers support for a normative set of security features such as:
- Access control, including multifactor authentication (MFA) and single sign on (SSO) 
- Encryption for data both in transit and at rest (SSL/TLS and HTTPS)
- Compliance with current healthcare industry regulations (HIPPA, GDPR, HL7)
- Real time monitoring and alerting, as well as logging and auditing

## Old Castle-and-Moat Security Model
In the traditional “castle-and-moat” approach, organizations rely on features like those provided by Mirth Connect, in
addition to firewalls and VPNs to protect resources inside a network perimeter. 

### But this is simply not enough.

Once an attacker gains any level of access—say through a phished VPN credential or a zero-day 
exploit—the entire “soft underbelly” of the internal network becomes vulnerable. This is especially dangerous in 
healthcare, where clinical data holds high value and can be easily exploited.

While these features and practices may be beneficial, they do not enforce the recommendations of modern security 
standards, such as the guidelines released last year by the Cybersecurity & Infrastructure Security Agency (CISA), who 
recommends a True Zero-Trust model for network access. The current normative methodologies fall very short of this in 
their centralization, reliance on shared secrets, and lack of attributability.

## Securing Data Exchange With RACK and Locksmith [↑](#top)
The ultimate expression of this solution is signed data everywhere. We achieve this through our Encrypt Send Sign Recieve
(ESSR) protocol, which is only viable by way of keeping keys at the edge through Key Event Receipt Infrastructure (KERI)
identifiers and architecture ...

How this achieves true zero trust
...

<a name="tutorial-overview"></a>
## Tutorial Overview [↑](#top)
We will use docker compose to set up four containers, which should be considered as two pairs of containers. Each pair
consists of a Mirth Connect Container and a RACK container. Each pair represent one side of a one-way health information
data exchange. In this configuration, one Mirth Connect instance is designated solely for sending data, while the other is 
designated solely for receiving data. Although the principles detailed here could easily be adapted for a two-way 
exchange, in this case, the configuration is explicitly designed to secure data flowing in only one direction.

Consider the following designations:

**M-R_S (Mirth Connect Rack Sender)** : A Mirth Connect and RACK instance pair designated as the sender of information. 
This pair is connected out of the box, per the docker compose example.

**M-R_R (Mirth Connect Rack Receiver)** : A Mirth Connect and RACK instance pair designated as the receiver of information.
This pair is connected out of the box, per the docker compose example.

Though each member of a given pair will come preconnected to the other member of that pair, but M-R_S will not be 
pre-connected to M-R_R. In this tutorial, we will be securely configuring and administrating the connection between 
M-R_S and M-R_R via an intermediary application called Locksmith.

Locksmith has inbuilt RACK functionality, which, when coupled with two local instances of rack, allows for the 
configuration and administration of the connection between M-R_S and M-R_R to be secured in the same manner as the 
connection itself. See the dotted 'Admin' lines in the following diagram. The 'Admin' lines are dotted because once the 
connection between M-R_S and M-R_R has been established, it is no longer necessary to maintain the administrative
connection to Locksmith.

### Tutorial Goal Diagram
<img src="gettingStartedImages/GettingStarted5.png"/>

<a name="setup-mirth-images-via-docker-compose"></a>
## Setup Mirth Images via Docker Compose [↑](#top)

Follow the instructions in `README.md` to set up and run the `mirth-connect-rack-compose-sample.yaml` via docker compose. 
Once the docker compose specified in the .yaml is running, you will have the following components set up:

<img src="./gettingStartedImages/GettingStarted1.png"/>

<a name="setup-and-install-rack-locally"></a>
## Setup and Install RACK Locally [↑](#top)
Download the RACK wheel from:
```bash
XXX
```

Create a new python venv with Python 3.12.8: 
```bash
python -m venv ./rack
```

Install the RACK Python library with:
```bash
pip install rack-1.0.0-py3-none-any.whl
```

Copy `passid.cesr` from `./examples/data` into the `./rack` venv

<a name="start-local-rack-gateways"></a>
## Start Local RACK Gateways [↑](#top)

### Sender Administration Gateway
This gateway, coupled with Locksmith, will administer and configure the rack instance associated with M-R_S. 
Install the gateway with:
```bash
rack install --name Outbound --salt DYA2LrpDmnk1xgI4ADxbc --passid-file ./passid.cesr
```
Then, in a seperate terminal, start the gateway with:
```bash
rack start --name Outbound
```

### Receiver Administration Gateway
This gateway, coupled with locksmith, will administer and configure the rack instance associated with M-R_R. 
Install the gateway with:
```bash
rack install --name Inbound --salt Bd8VBggWxGP-OjI7R4vxM --passid-file ./passid.cesr --admin-port 17632
```

Then, in a seperate terminal, start the gateway with:
```bash
rack start --name Inbound --metrics-port 9002
```

<a name="install-locksmith-and-setup-proxies"></a>
## Install Locksmith and Setup Proxies [↑](#top)
Follow OS-specific install instructions or download and install Locksmith wheel (reference RACK wheel install(link)) from:
```bash
XXX
```

At this point the state of your data exchange system should be represented by the following diagram:

<img src="gettingStartedImages/GettingStarted2.png"/>

The dashed line seperates your actual local environment (below the line) from a docker based simulation of a non-local
environment (above the line).

### Launch Locksmith

### Create a new vault called "Locksmith"

<div style="display: flex; justify-content: space-between;">
  <img src="./gettingStartedImages/Locksmith1.jpeg" style="width: 32%;">
  <img src="./gettingStartedImages/Locksmith2.jpeg" style="width: 32%;">
  <img src="./gettingStartedImages/Locksmith3.jpeg" style="width: 32%;">
</div>

-----

### Open the "Locksmith" vault

<div style="display: flex; justify-content: space-between;">
  <img src="./gettingStartedImages/Locksmith1.jpeg" style="width: 32%;">
  <img src="./gettingStartedImages/Locksmith4.jpeg" style="width: 32%;">
  <img src="./gettingStartedImages/Locksmith5.jpeg" style="width: 32%;">
</div>

-----

### Create an Identifier named "admin" using the salt `DQ7Hzp4faFdbesNx-_a1v`

<div style="display: flex; justify-content: space-between;">
  <img src="./gettingStartedImages/Locksmith6.jpeg" style="width: 32%;">
  <img src="./gettingStartedImages/Locksmith7.jpeg" style="width: 32%;">
  <img src="./gettingStartedImages/Locksmith8.jpeg" style="width: 32%;">
</div>

-----

### Ensure "admin" AID is `EK4iFDRWMPH2mJ_VSJZt5VgCTg7wupzKX5nipreSOBuR`

<img src="gettingStartedImages/Locksmith9.jpeg"/>

-----

### Connect Inbound and Outbound Remote Identifiers
- Connect a Remote Identifier called "Outbound" using the file "Outbound-core.cesr" created during the first install of RACK
- Connect a Remote Identifier called "Inbound" using the file "Inbound-core.cesr" created during the first install of RACK

<div style="display: flex; justify-content: space-between;">
  <img src="./gettingStartedImages/Locksmith10.jpeg" style="width: 48%;">
  <img src="./gettingStartedImages/Locksmith11.jpeg" style="width: 48%;">
</div>

-----

### Ensure Correct AIDs for Remote Identifiers
- Ensure the "Outbound" remote identifier's AID is `EPIa-VqM9y2EUUMAJ0MAv5AEdDVvaOcFmIxKn5jzIgKk`
- Ensure the "Inbound" remote identifier's AID is `EJ8Rx6lal6S7mlrhp6OuHkxAizP7N5ufzllu4YIbjjvV`

<img src="gettingStartedImages/Locksmith12.jpeg"/>

-----

### Create Two Proxy Redirects
- Create a new proxy, for Local AID, choose "admin" and for Remote AID choose "Outbound".  Ensure that port 15632 shows 
up as the port.

- Create a new proxy, for Local AID, choose "admin" and for Remote AID choose "Inbound".  Ensure that port 17632 shows 
up as the port.

<div style="display: flex; justify-content: space-between;">
  <img src="./gettingStartedImages/Locksmith13.jpeg" style="width: 48%;">
  <img src="./gettingStartedImages/Locksmith14.jpeg" style="width: 48%;">
</div>

-----

<img src="gettingStartedImages/GettingStarted3.png"/>

-----

### Launch The Proxies
Using the context menu for each Proxy, Launch the proxies. A RACK Adminstration console web tab should open for 
each RACK gateway.
<div style="display: flex; justify-content: space-between;">
  <img src="./gettingStartedImages/Locksmith15.jpeg" style="width: 48%;">
  <img src="./gettingStartedImages/Locksmith16.jpeg" style="width: 48%;">
</div>

-----

<img src="./gettingStartedImages/Locksmith17.png">

-----

At this point the state of your data exchange system should be represented by the following diagram. The seperating line 
between local and simulated non-local has been removed for visual clarity.

<img src="gettingStartedImages/GettingStarted4.png"/>

Now all that's left is to establish the connection between M-R_S and M-R_R via the RACK administration console web tabs.

<a name="connect-mirth-instances-with-rack-admin-via-locksmith"></a>
## Connect Mirth Instances with RACK Admin via Locksmith [↑](#top)

### In the Outbound administrator console
Create a local identifier named Outbound. Make sure the signing keys, rotation keys, 
signing threshold, and rotation threshold are all set to 1. This is the root delegator for the outbound gateway and 
will automatically create 10 signing AIDs, which will be rotated through as they sign and reach their thresholds. 

Create an outbound route. Name the route "To-Inbound". Set the "Route Type" to Peer-to-Peer. Leave "Send to 
Remote Gateway" blank for now, since we have not yet configured a remote gateway. Select Outbound as the "Local 
Identifier to Secure the connection". "Listening Protocol" is HTTP listening on port 3333. Save the route.

In the actions menu for the route, select "Export Introduction". This is a .cesr file that will be used to connect with
the Inbound gateway.

### In the Inbound administrator console
Create a local identifier named Inbound. Make sure the signing keys, rotation keys, signing threshold, 
and rotation threshold are all set to 1. This is the root delegator for the inbound gateway and will automatically 
create 10 signing AIDs, which will be rotated through as they sign and reach the thresholds. 

Create a Remote Gateway. Name it Outbound. Select the .cesr file exported from the "Outbound" "To-Inbound" route in the 
"Outbound" administrator console. The file should be named Outbound-To-Inbound.cesr. Click Save. Verify the AID for 
this remote gateway is the same as the AID of the Outbound identifier (created in the other administrator console).

Create an inbound route. Name it From-Outbound. "Route Type" is Peer-to-Peer. "Accept from Remote Gateway" is Outbound.
"Accept on Host" is docker host (172.21.0.2). "Accept on Port" is 4444. Select Inbound as "Local Identifier to
Secure Connection". Forward To "Protocol" should be HTTP, "IP Address / Host Name" should be 127.0.0.1, "Port" should 
be 5555.

Export the inbound route introduction.  

### In the Outbound administrator console
Create a remote gateway. Name it Inbound. Select the .cesr file exported from the "From-Outbound" Route in the 
"Inbound" administrator console. The file should be named Inbound-From-Outbound.cesr. Click Save. Verify the 
AID for this remote gateway is the same as the AID of the Inbound identifier (created in the other administrator console)

Go to the outbound route. In the actions menu, select edit. for "Send to Remote Gateway", select Inbound. Click
Save. Return to the actions menu and click launch

### In the Inbound administrator console
Go to inbound route. In the actions menu, click launch


Download the docker container healthkeri/rack-mirth-sample:1.0.0 with
```bash
docker pull healthkeri/rack-mirth-sample:1.0.0
```

Mount local directory to /opt/rack/data

Copy the core.cesr files out of the RACK images:
docker cp images-rack-1-1:/opt/rack/data/core.cesr .

<a name="license"></a>
## License [↑](#top)

The Dockerfiles, entrypoint script, and any other files used to build these Docker images are Copyright © healthKERI and 
licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.txt).

You can find a copy of the RACK license in [LICENSE.txt](https://github.com/healthkeri/rack/blob/development/LICENSE).