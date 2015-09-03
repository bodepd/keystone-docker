FROM ubuntu:14.04
MAINTAINER Dan Bode <dan@bodeco.io>
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-all python-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q gcc git python-dev python-lxml
WORKDIR /opt
RUN git clone http://github.com/jiocloud/keystone.git
WORKDIR /opt/keystone
RUN pip install -r requirements.txt
RUN python setup.py install
## Start Keystone
RUN echo "#!/bin/bash" > /root/postlaunchconfig.sh
RUN echo "/usr/local/bin/keystone-manage db_sync" >> /root/postlaunchconfig.sh
RUN echo "/usr/local/bin/keystone-all" >> /root/postlaunchconfig.sh
RUN chmod 755 /root/postlaunchconfig.sh

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

EXPOSE 35357
EXPOSE 5000
CMD /usr/local/bin/keystone-all --verbose --debug
