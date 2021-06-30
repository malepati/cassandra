FROM alpine:3.14.0

ARG CASSANDRA_VERSION
ENV CASSANDRA_VERSION=${CASSANDRA_VERSION}
ENV CASSANDRA_HOME=/etc/cassandra
ENV CASSANDRA_CONF=/etc/cassandra/conf
ENV PATH=${PATH}:${CASSANDRA_HOME}/bin:${CASSANDRA_HOME}/tools/bin
ENV MAX_HEAP_SIZE=1G

RUN apk add --no-cache bash su-exec openntpd linux-pam openjdk8-jre-base=8.282.08-r1 python2 && \
    wget -O- http://archive.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz | tar zx && \
    mv apache-cassandra-${CASSANDRA_VERSION} ${CASSANDRA_HOME} && \
    rm -rf ${CASSANDRA_HOME}/{javadoc,doc,CASSANDRA-14092.txt,CHANGES.txt,NEWS.txt,NOTICE.txt} && \
    addgroup -S cassandra && \
    adduser -S -G cassandra cassandra -s /bin/bash

# Expose desired ports 7000(storage), 7001(storage-ssl), 7199(jmx), 7777(jolokia), 9042(client)
EXPOSE 7000 7001 7001 7199 7777 9042

# Copy files
COPY files_to_copy/ /

# Entrypoint
ENTRYPOINT ["/etc/entrypoint.sh"]
