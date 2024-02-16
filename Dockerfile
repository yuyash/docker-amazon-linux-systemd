FROM public.ecr.aws/amazonlinux/amazonlinux:2
LABEL version="1.0"
LABEL description="Amazon Linux 2 with systemd enabled."

# Packages
RUN yum -y update; 
RUN yum -y groupinstall AMI

# Systemd
ENV container=docker
RUN yum -y install systemd ; \
    cd /lib/systemd/system/sysinit.target.wants/ ; \
    for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -f $i ; done ; \
    rm -f /lib/systemd/system/multi-user.target.wants/* ; \
    rm -f /etc/systemd/system/*.wants/* ; \
    rm -f /lib/systemd/system/local-fs.target.wants/* ; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* ; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* ; \
    rm -f /lib/systemd/system/basic.target.wants/* ; \
    rm -f /lib/systemd/system/anaconda.target.wants/*

# Clean cache
RUN yum -y clean all && rm -rf /var/cache

CMD /usr/lib/systemd/systemd
