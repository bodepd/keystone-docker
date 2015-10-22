#!/bin/bash
bash /opt/keystone/runtime-configure-keystone.sh
/usr/local/bin/keystone-manage db_sync
/usr/local/bin/keystone-all
