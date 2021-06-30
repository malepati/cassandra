#!/usr/bin/env bash
echo "Setting required linux settings -> swapoff -> ntpd -> diabling transparent_hugepage"
sysctl -p /etc/sysctl.conf
swapoff -a
ntpd
echo never | tee /sys/kernel/mm/transparent_hugepage/defrag
CPU_CORES=$(nproc --all)

__stop_cassandra(){
    echo "Stopping Cassandra: disable gossip -> flush node -> drain node -> stop cassandra"
    nodetool disablegossip
    nodetool flush
    nodetool drain
    nodetool stopdaemon
}

# Traping signal from pod
trap '__stop_cassandra; exit' TERM SIGTERM QUIT SIGQUIT INT SIGINT KILL SIGKILL

echo "updating config"
[ ! -z "${REPLACE_CLUSTER_NAME}" ] && sed -i "s/REPLACE_CLUSTER_NAME/${REPLACE_CLUSTER_NAME}/" ${CASSANDRA_CONF}/cassandra.yaml
[ ! -z "${SEEDS}" ] && sed -i "s/seeds: \"127.0.0.1\"/seeds: \"${SEEDS}\"/" ${CASSANDRA_CONF}/cassandra.yaml
[ ! -z "${BROADCAST_IP}" ] && sed -i "s/: 127.0.0.1/: ${BROADCAST_IP}/g" ${CASSANDRA_CONF}/{cassandra.yaml,cassandra-env.sh}
[ ! -z "${CPU_CORES}" ] && sed -i "s/#concurrent_compactors/concurrent_compactors: ${CPU_CORES}/" ${CASSANDRA_CONF}/cassandra.yaml
[ ! -z "${CPU_CORES}" ] && sed -i "s/#concurrent_writes/concurrent_writes: $((${CPU_CORES}*8))/" ${CASSANDRA_CONF}/cassandra.yaml
if [ "${SSL_ENABLED}" == "true" ]; then
    if [ ! -z "${KEYSTORE_TRUSTSTORE_PASSWORD}" ]; then
        until [[ -f ${CASSANDRA_CONF}/keystore.jks && -f ${CASSANDRA_CONF}/truststore.jks ]] ; do
            echo "SSL enabled but keystore.jks and truststore.jks files dont exist hence sleeping 10s and trying again"
            sleep 10
        done
cat >> ${CASSANDRA_CONF}/cassandra.yaml <<EOF
server_encryption_options:
    internode_encryption: all
    keystore: ${CASSANDRA_CONF}/keystore.jks
    keystore_password: '${KEYSTORE_TRUSTSTORE_PASSWORD}'
    truststore: ${CASSANDRA_CONF}/truststore.jks
    truststore_password: '${KEYSTORE_TRUSTSTORE_PASSWORD}'
client_encryption_options:
    enabled: true
    optional: false
    keystore: ${CASSANDRA_CONF}/keystore.jks
    keystore_password: '${KEYSTORE_TRUSTSTORE_PASSWORD}'
    truststore: ${CASSANDRA_CONF}/truststore.jks
    truststore_password: '${KEYSTORE_TRUSTSTORE_PASSWORD}'
EOF
    else
        echo "KEYSTORE_TRUSTSTORE_PASSWORD is not set hence exiting"
        exit 1
    fi
fi

# Customize cassandra-rackdc.propertiies file update logic

echo "Setting cassandra ownership to required directories"
chown -R cassandra:cassandra ${CASSANDRA_HOME}

su-exec cassandra cassandra -f -Dcassandra.config=file://${CASSANDRA_CONF}/cassandra.yaml
