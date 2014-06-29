#!/bin/sh
cd /var/www/shirasagi
mongod &
/bin/bash -l -c "bundle exec rake db:create_indexes"
/bin/bash -l -c "bundle exec rake ss:user:create data='{ name: \"user\", email: \"user@example.jp\", password: \"pass\" }'"
/bin/bash -l -c "bundle exec rake ss:site:create data='{ name: \"Your Site\", host: \"www\", domains: \"localhost:3000\" }'"
/bin/bash -l -c "bundle exec rake db:seed name=demo site=www"

# start rails server
#bundle exec thin -d
