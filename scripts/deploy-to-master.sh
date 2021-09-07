#!/usr/bin/env bash
echo "Deploy script started in deploy-to-master"
cd /opt/nginx/html/backend-v2.1
git pull origin development
bundle install
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake db:seed
/etc/init.d/nginx restart
echo "Deploy script finished execution"