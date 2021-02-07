FROM alpine:3.13.1

ARG CASSANDRA_VERSION
ENV CASSANDRA_VERSION=${CASSANDRA_VERSION}
ENV CASSANDRA_HOME=/usr/lib/cassandra
ENV CASSANDRA_CONF=/usr/lib/cassandra/conf
ENV PATH=${PATH}:${CASSANDRA_HOME}/bin:${CASSANDRA_HOME}/tools/bin
ENV MAX_HEAP_SIZE=1G

RUN apk add --no-cache bash su-exec openntpd linux-pam openjdk8-jre-base=8.272.10-r4 python2 && \
    wget -O- http://archive.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz | tar zx && \
    mv apache-cassandra-${CASSANDRA_VERSION} ${CASSANDRA_HOME} && \
    rm -rf ${CASSANDRA_HOME}/javadoc && \
    addgroup -S cassandra && \
    adduser -S -G cassandra cassandra -s /bin/bash

# Expose desired ports 7000(storage), 7001(storage-ssl), 7199(jmx), 7777(jolokia), 9042(client)
EXPOSE 7000 7001 7001 7199 7777 9042

# Copy files
COPY files_to_copy/ /

# Entrypoint
ENTRYPOINT ["/etc/entrypoint.sh"]
