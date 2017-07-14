# haproxy-bamboo
run haproxy-bamboo image as follow
	docker run -it --net=host --restart=always --name bamboo  \
		--log-opt max-file=10 --log-opt max-size=20k \
		-e MARATHON_ENDPOINT=http://192.168.10.118:8443 \
		-e MARATHON_USER=admin \
		-e MARATHON_PASSWORD=marathon \
		-e BAMBOO_ENDPOINT=http://192.168.10.200:8443 \
		-e BAMBOO_ZK_HOST=192.168.10.118:2181 \
		-e BAMBOO_ZK_PATH=/bamboo-https \
		-e HAPROXY_STATS_PORT=9443 \
		-e BAMBOO_HOST=192.168.10.200 \
		-e BAMBOO_CONFIG_PATH=/opt/bamboo/config/production.json \
		-e BAMBOO_DOCKER_AUTO_HOST=true \
		-e BAMBOO_PORT=8443 \
		-e BIND=:8443 \
		-e BAMBOO_TYPE=bamboo-https \
		-e HAPROXY_PROXY_PORT=443 \
		-v /applog/bamboo:/opt/bamboo/logs:rw \
		haproxy:2.2 /docker-entrypoint.sh
