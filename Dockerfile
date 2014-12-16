FROM phusion/baseimage

MAINTAINER Alinoor Rahman

ADD init.ora /
ADD initXETemp.ora /
# ADD oracle-xe_11.2.0-1.0_amd64.deb /tmp/
ADD https://s3-eu-west-1.amazonaws.com/9a49db77-77a0-4bed-8ffc-6a621424b9e1/oracle-xe_11.2.0-1.0_amd64.deb /tmp/
ADD 01_update_xe_listener_ora.sh /etc/my_init.d/

ENV DEBIAN_FRONTEND noninteractive

RUN chmod 755 /etc/my_init.d/01_update_xe_listener_ora.sh && \
	apt-get update && \
	apt-get install -y libaio1 net-tools bc && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	ln -s /usr/bin/awk /bin/awk && \
	mkdir /var/lock/subsys && \
	dpkg --install /tmp/oracle-xe_11.2.0-1.0_amd64.deb && \
	mv /init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts && \
	mv /initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts && \
	printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure && \
	printf admin\\nadmin\\n | passwd root && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://github.com/phusion/baseimage-docker#container_administration
# RUN /usr/sbin/enable_insecure_key
# RUN printf admin\\nadmin\\n | passwd root

RUN echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/bash.bashrc
RUN echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc
RUN echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc

EXPOSE 22
EXPOSE 1521
EXPOSE 8080

