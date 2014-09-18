#!/bin/bash

# Provision script created for Ubuntu 14.04

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_USER="$( stat -c '%U' ${APP_DIR} )"

if [ -d "/vagrant" ]; then
  # Control will enter here if $DIRECTORY exists.
  APP_DIR="/vagrant"
  APP_USER="vagrant"
fi

if [ "${APP_USER}" == "root" ]; then
    echo "Installing app as root is not recommended"
    echo "Username is determined by owner of application directory."
fi

echo "Provisioning..."
sudo apt-get update
sudo apt-get install -y software-properties-common python-software-properties
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install -y python build-essential git libpcre3-dev \
python-pip python-virtualenv python-dev pkg-config curl libxml2-dev libxslt1-dev zlib1g-dev \
libffi-dev nodejs libyaml-dev

# Default cache is memoization

# Redis
# add-apt-repository -y chris-lea/redis-server
# add-apt-repository -y chris-lea/python-redis
# apt-get update
# apt-get install -y redis-server

# Default DB is sqlite

# Mysql
# apt-get install -y mysql-server mysql-client

# MariaDB
# apt-get install -y mariadb-server mariadb-client

# Postgres
# apt-get install -y postgresql postgresql-contrib

# Install frontend assets
sudo npm install -g bower
sudo -iu ${APP_USER} bower --config.cwd=${APP_DIR} --config.directory=realms/static/vendor --config.interactive=false install

sudo -iu ${APP_USER} virtualenv ${APP_DIR}/.venv

sudo -iu ${APP_USER} ${APP_DIR}/.venv/bin/pip install ${APP_DIR}

echo "Installing start scripts"
sudo ln -s ${APP_DIR}/.venv/bin/realms-wiki /usr/local/bin/realms-wiki
sudo chmod +x /usr/local/bin/realms-wiki

cat << EOF > /etc/init/realms-wiki.conf
description "Realms Wiki"
author "scragg@gmail.com"
setuid ${APP_USER}
setgid ${APP_USER}
start on runlevel [2345]
stop on runlevel [!2345]
respawn
exec /usr/local/bin/realms-wiki run
EOF