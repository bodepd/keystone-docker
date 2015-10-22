#!/bin/bash
# Config file to override certain keystone config,
# namely the part of the config that needs to connect
# to the database so that I can use docker links

# TODO this should allow any config to be overridden

if [ -z "${DB_PORT_3306_TCP_ADDR}" ]; then
  echo 'DB_PORT_3306_TCP_ADDR must be set, maybe you did not link it?'
  exit 1
fi

if [ -z "${ADMIN_TOKEN}" ]; then
  echo 'Admin token not set'
  exit 1
fi

connection="mysql://${MYSQL_USER:-keystone}:${MYSQL_PASSWORD:-keystone}@${DB_PORT_3306_TCP_ADDR}/${MYSQL_DATABASE:-keystone}"

crudini --set /etc/keystone/keystone.conf \
  database connection $connection

crudini --set /etc/keystone/keystone.conf \
  DEFAULT admin_token
