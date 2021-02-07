# Docker Cassandra Apline
Apache Cassandra Docker image on Alpine

## Creating locally
```
docker build -t cassandra:latest --build-arg CASSANDRA_VERSION=3.11.4 .
docker run --name cassandra -p=7199:7199 -p=9042:9042 --privileged cassandra:latest
```
