FROM registry.access.redhat.com/rhel7.3
WORKDIR /work

###
# add repo's
###
ADD slac-rhel-7-server.repo /etc/yum.repos.d/


###
# misc tools
###
# RUN yum -y install git openssh vim-enhanced
RUN yum -y install libtool git make gcc-c++ readline-devel ncurses-devel

###
# web server + php
###
RUN yum install -y python-setuptools python-devel
RUN yum install -y python-gunicorn python-flask MySQL-python
RUN curl -O "https://bootstrap.pypa.io/get-pip.py"
RUN python get-pip.py
RUN pip install subprocess32 eventlet


#  for i in `cat SECRETS_REQUIRED`; do echo 'mypassword' | docker secret create $i -; done
ENV LOGBOOK_AUTHDB_DEFAULT_HOST mysql
ENV LOGBOOK_AUTHDB_DEFAULT_PASSWORD changeme_authdb_password
ENV LOGBOOK_AUTHDB_DEFAULT_USER changeme_authdb_user
ENV LOGBOOK_LOGBOOK_DEFAULT_PASSWORD changeme_logbook_password
ENV LOGBOOK_LOGBOOK_DEFAULT_USER changeme_logbook_user
ENV LOGBOOK_LOGGER_DEFAULT_HOST mysql
ENV LOGBOOK_LOGGER_DEFAULT_PASSWORD  changeme_logger_password
ENV LOGBOOK_LOGGER_DEFAULT_USER changeme_logger_user
ENV LOGBOOK_REGDB_DEFAULT_HOST mysql
ENV LOGBOOK_REGDB_DEFAULT_LDAP_HOST ldaps://ldap603.slac.stanford.edu/
ENV LOGBOOK_REGDB_DEFAULT_PASSWORD changeme_regdb_password
ENV LOGBOOK_REGDB_DEFAULT_USER changeme_regdb_user


ENV ACCESS_LOG_FORMAT='%(h)s %(l)s %({REMOTE_USER}i)s %(t)s "%(r)s" %(s)s %(b)s %(D)s'

RUN pwd
COPY psdmauth /work/
RUN pwd
RUN ls -lah
RUN python setup.py install

COPY runtable_export /work/

WORKDIR /work

EXPOSE 5000

ENTRYPOINT ["gunicorn", "runtable_export:app", "-b 0.0.0.0:5000", "--worker-class", "eventlet",  "--log-level=DEBUG",  "--enable-stdio-inheritance", "--access-logfile", "-"]


