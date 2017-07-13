#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [[ -n $BAMBOO_DOCKER_AUTO_HOST ]]; then
sed -i "s/^.*Endpoint\": \"\(http:\/\/haproxy-ip-address:8000\)\".*$/    \"EndPoint\": \"http:\/\/$BAMBOO_HOST:$BAMBOO_PORT\",/" \
    ${CONFIG_PATH:=config/production.json}
fi
sed -i "s/HAPROXY_PROXY_PORT/${HAPROXY_PROXY_PORT}/g;s/HAPROXY_STATS_PORT/${HAPROXY_STATS_PORT}/g" /etc/haproxy/haproxy.cfg
sed -i "s/HAPROXY_PROXY_PORT/${HAPROXY_PROXY_PORT}/g;s/HAPROXY_STATS_PORT/${HAPROXY_STATS_PORT}/g" /opt/bamboo/config/haproxy_template.cfg
haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid
/opt/bamboo/bamboo -config=${BAMBOO_CONFIG_PATH:-/opt/bamboo/config/production.json} -bind=${BAMBOO_PORT:-8443} -log=/opt/bamboo/logs/${BAMBOO_TYPE}.log
