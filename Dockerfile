FROM centos
ENV HAPROXY_MAJOR 1.7
ENV HAPROXY_VERSION 1.7.5
ENV HAPROXY_MD5 ed84c80cb97852d2aa3161ed16c48a1c
ENV UID 1100
ENV GID 1100
ENV USER haproxy
ENV GROUP haproxy
#ADD haproxy.tar.gz  /
#ADD bamboo-0.2.15_1-1.x86_64.rpm /
# see http://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -x \
        \
        && buildDeps=' \
                gcc \
                make \
                wget \
                openssl \
                openssl-devel \
                net-tools \
        ' \
        && yum install -y $buildDeps  && yum clean all \
        \
        && wget -O haproxy.tar.gz "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" \
        && wget -O bamboo-0.2.15_1-1.x86_64.rpm "https://raw.githubusercontent.com/VFT/FileStore/master/bamboo/bamboo-0.2.15_1-1.x86_64.rpm" \
        && echo "$HAPROXY_MD5 *haproxy.tar.gz" | md5sum -c \
        && mkdir -p /usr/src/haproxy \
        && tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
        && rpm -ivh bamboo-0.2.15_1-1.x86_64.rpm \
        && rm haproxy.tar.gz \
        \
        && makeOpts=' \
                TARGET=linux3100 \
                USE_OPENSSL=1 \
                USE_PCRE=1 PCREDIR= \
                USE_ZLIB=1 \
        ' \
        && make -C /usr/src/haproxy -j "$(nproc)" all $makeOpts \
        && make -C /usr/src/haproxy install-bin $makeOpts \
        && make -C /usr/src/haproxy clean $makeOpts \
        \
        && mkdir -p /etc/haproxy/errors \
        && mkdir -p /var/lib/haproxy \
        && mkdir -p /run/haproxy \
        && groupadd -g $GID $GROUP \
        && useradd -u $UID -g $GID -m $USER \
        && cp -R /usr/src/haproxy/examples/errorfiles/* /etc/haproxy/errors \
        && mv /opt/bamboo/config/production.example.json /opt/bamboo/config/production.json \
        && rm -rf /usr/src/haproxy \
        && rm -rf bamboo-0.2.15_1-1.x86_64.rpm 
COPY haproxy.cfg /etc/haproxy/
COPY haproxy_template.cfg /opt/bamboo/config/
WORKDIR /opt/bamboo
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
