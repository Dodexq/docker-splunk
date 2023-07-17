FROM outcoldman/splunk:6.3.1-forwarder
LABEL maintainer="Artem Udodov"

ENV SPLUNK_BACKUP_DOCKER_APP ${SPLUNK_BACKUP_DEFAULT_ETC}/etc/apps/docker

RUN apt-get update \
    && apt-get install -y wget jq curl \
    && mkdir -p ${SPLUNK_BACKUP_DOCKER_APP}/bin \
    && wget -O docker-18.09.3.tgz 'https://download.docker.com/linux/static/stable/x86_64/docker-18.09.3.tgz' \
    && tar -xvf docker-18.09.3.tgz -C ${SPLUNK_BACKUP_DOCKER_APP}/bin \
    && chmod +x ${SPLUNK_BACKUP_DOCKER_APP}/bin/docker

ADD inputs.conf ${SPLUNK_BACKUP_DOCKER_APP}/default/
ADD props.conf ${SPLUNK_BACKUP_DOCKER_APP}/default/
ADD docker_inspect.sh ${SPLUNK_BACKUP_DOCKER_APP}/bin/
ADD docker_stats.sh ${SPLUNK_BACKUP_DOCKER_APP}/bin/
ADD docker_top.sh ${SPLUNK_BACKUP_DOCKER_APP}/bin/
ADD docker_events.sh ${SPLUNK_BACKUP_DOCKER_APP}/bin/

RUN chmod +x ${SPLUNK_BACKUP_DOCKER_APP}/bin/*.sh
