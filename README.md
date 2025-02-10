<a name="top"></a>
# Table of Contents

* [Supported tags and respective Dockerfile links](#supported-tags)
* [Supported Architectures](#supported-architectures)
* [Quick Reference](#quick-reference)
* [What is Routing, Authentication and Confidentiality with KERI (RACK)](#what-is-rack)
* [How to use this image](#how-to-use)
    * [Start a Connect instance](#start-rack)
    * [Using `docker stack deploy` or `docker-compose`](#using-docker-compose)
    * [Environment Variables](#environment-variables)
        * [RACK environment variables](#rack-environment-variables)
    * [Using Docker Secrets](#using-docker-secrets)
    * [Using Volumes](#using-volumes)
        * [The /usr/local/var/keri folder](#the-keri-folder)
        * [Additional extensions](#additional-extensions)
* [License](#license)

------------

<a name="supported-tags"></a>
# Supported tags and respective Dockerfile links [↑](#top)

##### Python 3.12-8 Debian Bookworm

* [1.0, 1.0.0, latest](https://github.com/healthKERI/rack-docker/blob/master/Dockerfile)

------------

<a name="supported-architectures"></a>
# Supported Architectures [↑](#top)

Docker images for RACK 1.0.0 and later versions support both `linux/amd64` and `linux/arm64` architectures.  As an example, to pull the latest `linux/arm64` image, use the command
```
docker pull --platform linux/arm64 healthkeri/rack:latest
```

------------

<a name="quick-reference"></a>
# Quick Reference [↑](#top)

#### Where to get help:

* [healthKERI Home](https://www.healthkeri.com/)
* [Connect Forum](https://forums.mirthproject.io/)
* [KERI Community Discord](https://discord.gg/NqZftZTKhW) (register [here](https://discord.gg/NqZftZTKhW))
* [RACK GitHub](https://github.com/healthKERI/rack)
* [RACK Docker GitHub](https://github.com/healthKERI/rack-docker)

#### Where to file issues:

* For issues relating to these Docker images:
    * https://github.com/healthkeri/rack-docker/issues
* For issues relating to the Connect application itself:
    * https://github.com/healthkeri/rack/issues

------------

<a name="what-is-rack"></a>
# What is Routing, Authentication and Confidentiality with KERI (RACK) [↑](#top)

An open-source security gateway focused on healthcare. For more information please visit our [GitHub page](https://github.com/healthkeri/rack).

<img src="https://raw.githubusercontent.com/healthKERI/rack-docker/refs/heads/main/docs/healthkeri-main-logo.png"/>

Sign Everything
The healthKERI RACK gateway is a radical new approach to Zero-Trust network access.  It leverages the Key Event Receipt Infrastructure (KERI) protocol to help healthcare organizations of all size move toward more robust security using techniques recommended by the Cybersecurity & Infrastructure Security Agency in [Modern Approaches to Network Access Security](https://www.cisa.gov/resources-tools/resources/modern-approaches-network-access-security).

The easiest way to discover the power of the healthKERI approaches of Sign Everything and Keys at the Edge is to give RACK a try using the Docker images defined in this repository.  We have written a [Getting Started](https://github.com/healthKERI/rack-docker/blob/master/docs/GETTING_STARTED.md) tutorial and accompanying Docker Compose files that can help you quickly start using two RACK Gateways to establish a secure connection between two [Mirth Connect](https://github.com/nextgenhealthcare/connect) integration engines exchanging FHIR data. 

------------

<a name="how-to-use"></a>
# How to use this image [↑](#top)

<a name="start-connect"></a>
## Start a Connect instance [↑](#top)

Quickly start RACK using the default Admin AID and PassID. At a minimum you will likely want to use the `-p` option to expose the 15632 port so that you can login to the Administrator GUI:

```bash
docker run -p 15632:15632 healthkeri/rack
```

You can also use the `--name` option to give your container a unique name, and the `-d` option to detach the container and run it in the background:

```bash
docker run --name myrack -d -p 15632:15632 healthkeri/rack
```

To run a specific version of RACK, specify a tag at the end:

```bash
docker run --name myrack -d -p 15632:15632 healthkeri/rack:1.0.0
```

To run using a specific architecture, specify it using the `--platform` argument:

```bash
docker run --name myrack -d -p 15632:15632 --platform linux/arm64 healthkeri/rack:1.0.0
```

Look at the [Environment Variables](#environment-variables) section for more available configuration options.

------------

<a name="using-docker-compose"></a>
## Using [`docker stack deploy`](https://docs.docker.com/engine/reference/commandline/stack_deploy/) or [`docker-compose`](https://github.com/docker/compose) [↑](#top)

With `docker stack` or `docker-compose` you can easily setup and launch multiple related containers. For example you might want to launch both Connect *and* a PostgreSQL database to run alongside it.

```bash
docker-compose -f stack.yml up
```

Here's an example `stack.yml` file you can use:

```yaml
version: "3.9"

services:
  rack:
    image: healthkeri/rack
    ports:
      - "15632:15632/tcp" # Maps host port 15632 to container port 15632
      - "4444:4444/tcp"
    environment:
      RACK_NAME: "Rack1"
      PORT: 15632
      SALT: 'DYA2LrpDmnk1xgI4ADxbc'  # For testing purposes, never put a salt in a file like this
      PASS_ID: /opt/rack/passid.cesr
      PASSCODE: 'DYA2LrpDmnk1xgI4ADxbc'
```

[![Try in PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)](http://play-with-docker.com/?stack=https://raw.githubusercontent.com/healthkeri/rack-docker/master/examples/play-with-docker-example.yaml)

Try it out with Play With Docker! Note that in order to access the 15632/4444 ports from your workstation, follow [their guide](https://github.com/play-with-docker/play-with-docker#how-can-i-connect-to-a-published-port-from-the-outside-world) to format the URL correctly. When you login to the Administration UI you must use [Locksmith](https://github.com/healthkeri/locksmith) to proxy your connection

There are other example stack files in the [examples directory](https://github.com/healthkeri/rack-docker/tree/master/examples)!

------------

<a name="environment-variables"></a>
## Environment Variables [↑](#top)

You can use environment variables to configure the [rack](https://github.com/healthkeri/rack) settings. More information on the available environment variables can be found in the [RACK User Guide](http://downloads.mirthcorp.com/rack-user-guide/latest/rack-user-guide.pdf).

To set environment variables, use the `-e` option for each variable on the command line:

```bash
docker run -e PORT=16632 -p 16632:16632 healthkeri/rack
```

You can also use a separate file containing all of your environment variables using the `--env-file` option. For example let's say you create a file **myenvfile.txt**:

```bash
RACK_NAME="Rack1"
PORT=15632
SALT=DYA2LrpDmnk1xgI4ADxbc
PASS_ID=/opt/rack/passid.cesr
PASSCODE=DYA2LrpDmnk1xgI4ADxbc
```

```bash
docker run --env-file=myenvfile.txt -p 15632:15632 healthkeri/rack
```

------------

<a name="rack-environment-variables"></a>
### RACK environment variables [↑](#top)

<a name="env-rack_name"></a>
#### `RACK_NAME`

The name of this instance of RACK, displayed in the Administration UI.

<a name="env-port"></a>
#### `PORT`

The network port for the Administration UI to listen on.


<a name="env-salt"></a>
#### `SALT`

The 21 character salt used to generate the hierarchical deterministic key chain for the Administrative KERI Autonomic IDentifier (AID). If you don't want to use an environment variable to store sensitive information like this, look at the [Using Docker Secrets](#using-docker-secrets) section below.

For example:
* `DYA2LrpDmnk1xgI4ADxbc`
<a name="env-pass-id"></a>
#### `PASS_ID`

The path to a Composable Event Streaming Representation (CESR) file containing the Key Event Log (KEL) of the KERI AID to use to authenticate against the Administration UI. If you don't want to use an environment variable to store sensitive information like this, look at the [Using Docker Secrets](#using-docker-secrets) section below.

For Example:
* `/opt/rack/passid.cesr`

<a name="env-passcode"></a>
#### `PASSCODE`

The 21 character passcode used to encrypt the local keystore for the RACK gateway. If you don't want to use an environment variable to store sensitive information like this, look at the [Using Docker Secrets](#using-docker-secrets) section below.


------------

<a name="using-docker-secrets"></a>
## Using Docker Secrets [↑](#top)

For sensitive information such as the keystore passcode or Administration credentials, instead of supplying them as environment variables you can use a [Docker Secret](https://docs.docker.com/engine/swarm/secrets/). This image supports one secret:

##### rack_properties

If present, any properties in this secret will be merged into the environment.

------------

Secrets are supported with [Docker Swarm](https://docs.docker.com/engine/swarm/secrets/), but you can also use them with [`docker-compose`](#using-docker-compose).

For example let's say you wanted to set `PASSCODE` and `SALT` in a secure way. You could create a new file, **secret.properties**:

```bash
PASSCODE=changeme
SALT=changeme
```

Then in your YAML docker-compose stack file:

```yaml
version: '3.1'
services:
  mc:
    image: healthkeri/rack
    environment:
      RACK_NAME: "Rack1"
      PORT: 15632
      PASS_ID: /opt/rack/passid.cesr
    secrets:
      - rack_properties
    ports:
      - "4444:4444/tcp"
      - "15632:15632/tcp"
secrets:
  mirth_properties:
    file: /local/path/to/secret.properties
```

The **secrets** section at the bottom specifies the local file location for each secret.  Change `/local/path/to/secret.properties` to the correct local path and filename.

Inside the configuration for the Connect container there is also a **secrets** section that lists the secrets you want to include for that container.

------------

<a name="using-volumes"></a>
## Using Volumes [↑](#top)

<a name="the-keri-folder"></a>
#### The /usr/local/var/keri folder [↑](#top)

The /usr/local/var/keri directory stores the LMDB databases of public key event log data, RACK configuration data and the keystore.

```bash
docker run -v /local/path/to/keri:/usr/local/var/keri -p 15632:15632 healthkeri/rack
```

The `-v` option makes a local directory from your filesystem available to the Docker container. Create a folder on your local filesystem, then change the `/local/path/to/keri` part in the example above to the correct local path.

You can also configure volumes as part of your docker-compose YAML stack file:

```yaml
version: '3.1'
services:
  mc:
    image: healthkeri/rack
    volumes:
      - ~/Documents/keri:/usr/local/var/keri
```

------------

<a name="license"></a>
# License [↑](#top)

The Dockerfiles, entrypoint script, and any other files used to build these Docker images are Copyright © healthKERI and licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.txt).

You can find a copy of the RACK license in [LICENSE.txt](https://github.com/healthkeri/rack/blob/development/LICENSE).