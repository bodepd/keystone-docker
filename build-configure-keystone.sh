#!/bin/bash
#
# make configurations to default keystone.conf file during build time
#
crudini --set /etc/keystone/keystone.conf \
  cache config_prefix cache.keystone

crudini --set /etc/keystone/keystone.conf \
  cache expiration_time 600

crudini --set /etc/keystone/keystone.conf \
  cache enabled True

crudini --set /etc/keystone/keystone.conf \
  cache backend_argument url:127.0.0.1:11211

crudini --set /etc/keystone/keystone.conf \
  cache cache_backend dogpile.cache.memcached

crudini --set /etc/keystone/keystone.conf \
  catalog driver keystone.catalog.backends.sql.Catalog

