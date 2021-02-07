#!/usr/bin/env bash
sysctl -p /etc/sysctl.conf
swapoff -a
ntpd
chown -R cassandra:cassandra /usr/lib/cassandra
su-exec cassandra cassandra -f
