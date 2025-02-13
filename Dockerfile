# Start with Python 3.12.8 Debian Bookworm base image
FROM python:3.12.8-bookworm

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install required dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    libsodium-dev \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
RUN python -m venv $VIRTUAL_ENV

# Copy wheel file into container
COPY rack/rack-1.0.0-py3-none-any.whl /tmp/

# Install wheel in virtual environment
RUN . $VIRTUAL_ENV/bin/activate && \
    pip install /tmp/rack-0.0.9-py3-none-any.whl && \
    rm /tmp/rack-0.0.9-py3-none-any.whl

# Create Mirth user and set ownership
RUN useradd -u 1001 -r -s /bin/false rack

# Set virtual environment permissions
RUN chown -R rack:rack $VIRTUAL_ENV

# Create directory for supervisor logs
RUN mkdir -p /var/log/rack && \
    chown -R rack:rack /var/log/rack

# Create directories for RACK
RUN mkdir -p /opt/rack && \
    mkdir -p /opt/rack/data && \
    mkdir -p /usr/local/var/keri

COPY <<EOF /opt/rack/rack.sh
source /opt/venv/bin/activate
if [ -n \"\$\{PASSCODE+x\}\" ]; then
  ARGS=\"\$\{ARGS\} --passcode \$\{PASSCODE\}\"
else
  ARGS=\"\"
fi

rack start --name \"\$\{RACK_NAME\}\" \$\{ARGS\}
EOF

COPY ./passid.cesr /opt/rack

RUN chown -R rack:rack /opt/rack && \
    chown -R rack:rack /usr/local/var/keri && \
    chmod +x /opt/rack/rack.sh

WORKDIR /opt/rack/data
COPY ./images/entrypoint.sh /
RUN chmod 755 /entrypoint.sh

USER rack

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["/opt/rack/rack.sh"]