FROM centos:7
ENV SPLUNK_HOME /splunkforwarder
ENV SPLUNK_ROLE splunk_heavy_forwarder
ENV SPLUNK_START_ARGS --accept-license
ENV SPLUNK_INDEXER_HOST so1

RUN yum install -y epel-release \
    && yum install -y wget expect jq

RUN wget -O splunkforwarder-7.2.4-8a94541dcfac-Linux-x86_64.tgz 'https://download.splunk.com/products/universalforwarder/releases/7.2.4/linux/splunkforwarder-7.2.4-8a94541dcfac-Linux-x86_64.tgz' \
    && wget -O docker-18.09.3.tgz 'https://download.docker.com/linux/static/stable/x86_64/docker-18.09.3.tgz' \
    && tar -xvf splunkforwarder-7.2.4-8a94541dcfac-Linux-x86_64.tgz \
    && tar -xvf docker-18.09.3.tgz  \
    && rm -f splunkforwarder-7.2.4-8a94541dcfac-Linux-x86_64.tgz \
    && rm -f docker-18.09.3.tgz

COPY [ "inputs.conf", "docker-stats/props.conf", "/splunkforwarder/etc/system/local/" ]
COPY [ "docker-stats/docker_events.sh", "docker-stats/docker_inspect.sh", "docker-stats/docker_stats.sh", "docker-stats/docker_top.sh", "docker-stats/docker_logs.sh", "/splunkforwarder/bin/scripts/" ]
COPY first_start.sh /splunkforwarder/bin/

RUN chmod +x /splunkforwarder/bin/scripts/*.sh \
    && groupadd -r splunk \
    && useradd -r -m -g splunk splunk \
    && echo "%sudo ALL=NOPASSWD:ALL" >> /etc/sudoers \
    && chown -R splunk:splunk $SPLUNK_HOME \
    && /splunkforwarder/bin/first_start.sh \
    && sleep 5 \
    && /splunkforwarder/bin/splunk add forward-server so1:9997 -auth 'adminforward:admin4orward' \
    && /splunkforwarder/bin/splunk restart 

COPY [ "init/entrypoint.sh", "init/checkstate.sh", "/sbin/" ]

VOLUME [ "/splunkforwarder/etc", "/splunkforwarder/var" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=3m --retries=5 CMD /sbin/checkstate.sh || exit 1

ENTRYPOINT [ "/sbin/entrypoint.sh" ]
CMD [ "start-service" ]
