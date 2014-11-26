FROM phusion/baseimage

MAINTAINER Alinoor Rahman

ADD chkconfig /sbin/chkconfig
ADD init.ora /
ADD initXETemp.ora /
ADD https://s3-eu-west-1.amazonaws.com/9a49db77-77a0-4bed-8ffc-6a621424b9e1/oracle-xe_11.2.0-1.0_amd64.deb /tmp/

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y libaio1 net-tools bc
RUN ln -s /usr/bin/awk /bin/awk
RUN mkdir /var/lock/subsys
RUN chmod 755 /sbin/chkconfig

RUN dpkg --install /tmp/oracle-xe_11.2.0-1.0_amd64.deb

RUN mv /init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts
RUN mv /initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts

RUN printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

RUN echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/bash.bashrc
RUN echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc
RUN echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc

EXPOSE 22
EXPOSE 1521
EXPOSE 8080

CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora; \
	service oracle-xe start; \
	/usr/sbin/sshd -D
