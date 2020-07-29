#!/bin/bash

export DB_HOST="mongodb://${db_host}:27017/posts" >> /home/ubuntu/.bashrc
# echo 'export DB_HOST=mongodb://99.0.2.217:27017/posts' >> /home/ubuntu/.bashrc

cd /home/ubuntu
. /home/ubuntu/.bashrc
# sudo service nginx restart

cd /home/ubuntu/app
forever start app.js

cd /home/ubuntu/app/seeds
node seed.js
