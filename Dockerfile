FROM python:2.7
MAINTAINER Artem Silenkov <artem.silenkov@gmail.com>

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo graphviz postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone and install netbox
ENV NETBOX_COMMIT 594ef71027630d07b0c02866c03bf55f1d23b527
RUN mkdir -p /usr/src/netbox \
    && git clone https://github.com/digitalocean/netbox.git /usr/src/netbox \
    && (cd /usr/src/netbox && pip install --no-cache-dir -r requirements.txt)

# Change workdir
WORKDIR /usr/src/netbox/netbox

# Create user
RUN groupadd -g 1000 netbox \
    && useradd -u 1000 -g 1000 -d /usr/src/netbox netbox \
    && chown -R netbox: /usr/src/netbox

# Setup entrypoint
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

# Expose ports
EXPOSE 8888/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["runserver", "--insecure", "0.0.0.0:8888"]
