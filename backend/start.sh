# !/bin/bash

export BASE_PATH=/opt
export TEMPLATE_PATH=${BASE_PATH}/template
export SERVICE_PATH=${BASE_PATH}/backend

# load environment variable

source ${BASE_PATH}/default_value.sh

# construct config files

envsubst < ${TEMPLATE_PATH}/settings_template.py > ${SERVICE_PATH}/conduit/settings.py
envsubst < ${TEMPLATE_PATH}/uwsgi_template.ini > ${BASE_PATH}/uwsgi.ini
envsubst < ${TEMPLATE_PATH}/nginx_template.conf > /etc/nginx/nginx.conf

mkdir /etc/nginx/sites-available/
envsubst < ${TEMPLATE_PATH}/service_template.conf > /etc/nginx/sites-available/service.conf
ln -s /etc/nginx/sites-available/service.conf /etc/nginx/sites-enabled/

# wait until database up

while !</dev/tcp/${DATABASE_HOST}/${DATABASE_PORT};
do
  sleep 1
  echo "wait for database up..."
done

# start service

python ${SERVICE_PATH}/manage.py migrate
/etc/init.d/nginx start
uwsgi --ini ${BASE_PATH}/uwsgi.ini
#sleep infinity
