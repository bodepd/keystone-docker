FROM ubuntu:14.04
MAINTAINER Dan Bode <dan@bodeco.io>
RUN apt-get update
# install python deps
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-all python-pip
# install pip build deps
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q gcc git python-dev python-lxml
# install non-required keystone dependent packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-mysqldb
WORKDIR /opt
RUN git clone http://github.com/jiocloud/keystone.git
WORKDIR /opt/keystone
RUN pip install -r requirements.txt
RUN python setup.py install

# weird stuff I had to do

# for some reason oslo utils get installed in oslo_utils instead of oslo/utils
# so it can't be found
#  File "/usr/local/bin/keystone-all", line 44, in <module>
#    from keystone.common import dependency
#  File "/usr/local/lib/python2.7/dist-packages/keystone/common/dependency.py", line 29, in <module>
#    from keystone import notifications
#  File "/usr/local/lib/python2.7/dist-packages/keystone/notifications.py", line 21, in <module>
#    from oslo import messaging
#  File "/usr/local/lib/python2.7/dist-packages/oslo/messaging/__init__.py", line 18, in <module>
#    from .notify import *
#  File "/usr/local/lib/python2.7/dist-packages/oslo/messaging/notify/__init__.py", line 22, in <module>
#    from .notifier import *
#  File "/usr/local/lib/python2.7/dist-packages/oslo/messaging/notify/notifier.py", line 27, in <module>
#    from oslo.utils import timeutils
#ImportError: No module named utils
RUN sudo cp -Rvf /usr/local/lib/python2.7/dist-packages/oslo_utils /usr/local/lib/python2.7/dist-packages/oslo/utils

# tmp using these ports so that I can drop it in with as few modifications as possible
# b/c it chooses to bind ports based on config settings. I will update that config
# as part of a bigger patch
EXPOSE 35358
EXPOSE 15000

## Start Keystone
RUN echo "#!/bin/bash" > /root/postlaunchconfig.sh
RUN echo "/usr/local/bin/keystone-manage --config-dir=/opt/keystone/conf db_sync" >> /root/postlaunchconfig.sh
RUN echo "/usr/local/bin/keystone-all --config-dir=/opt/keystone/conf --verbose --debug" >> /root/postlaunchconfig.sh
RUN chmod 755 /root/postlaunchconfig.sh

RUN mkdir /var/log/keystone
CMD /root/postlaunchconfig.sh
