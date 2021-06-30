# Docker Cassandra Apline
Apache Cassandra Docker image on Alpine

## Creating locally
```
docker build -t cassandra:latest --build-arg CASSANDRA_VERSION=3.11.9 .
docker run --name cassandra -p=7199:7199 -p=9042:9042 --privileged --rm -it cassandra:latest
```

## ENV variables
```
CASSANDRA_VERSION: Apache Cassandra version i.e. 3.11.9, 2.2..19, 2.1.22
CASSANDRA_HOME: Defaulted to /etc/cassandra
CASSANDRA_CONF: Defaulted to /etc/cassandra/conf
MAX_HEAP_SIZE: Defaulted to 1G
REPLACE_CLUSTER_NAME: Cluster name to be configured
SEEDS: Seeds to be configured
BROADCAST_IP: Broadcast IP to be configured
SSL_ENABLED: SSL enabling flag (will be waiting for keystore.jks and truststore.jks to be present at CASSANDRA_CONF)
KEYSTORE_TRUSTSTORE_PASSWORD: Password of keystore and truststore
```
