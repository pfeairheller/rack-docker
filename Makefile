
.PHONY: build-rack-mirth-sample build-rack

VERSION=1.0.0

define DOCKER_WARNING
In order to use the multi-platform build enable the containerd image store
The containerd image store is not enabled by default.
To enable the feature for Docker Desktop:
	Navigate to Settings in Docker Desktop.
	In the General tab, check Use containerd for pulling and storing images.
	Select Apply and Restart."
endef

build-mirth-cli: .warn
	@docker build --platform=linux/amd64,linux/arm64 -f Dockerfile-mirth-cli -t healthkeri/mirth-with-cli:$(VERSION) .

build-rack: .warn
	@docker build --platform=linux/amd64,linux/arm64 -f Dockerfile -t healthkeri/rack:$(VERSION) .

publish-rack-mirth-sample:
	@docker push healthkeri/rack-mirth-sample:$(VERSION)

publish-rack:
	@docker push healthkeri/rack:$(VERSION)

.warn:
	@echo -e ${RED}"$$DOCKER_WARNING"${NO_COLOUR}

RED="\033[0;31m"
NO_COLOUR="\033[0m"
export DOCKER_WARNING
