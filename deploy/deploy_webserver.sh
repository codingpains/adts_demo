#!/bin/sh

# Pull code
echo "\n\nDeleting all changes in repository"
git reset --hard
echo "-- Checkout correct branch: git checkout master"
git checkout master
echo "-- Get latest changes: git pull"
git pull

# Install dependencies
echo "-- Install dependencies: npm install"
npm install

# Kill previous workers
echo "-- Stop and remove all existing instances"
pm2 stop adt-web-server
pm2 delete adt-web-server

# Start new workers
echo "-- Start new insances: pm2 start ./deploy/pm2-webserver.json --env production"
pm2 start /home/deploy/apps/adts_demo/pm2_webserver.json --env production

# Deal with NGINX
echo "-- Remove default site if it exits"
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

echo "-- Override NGINX config file for this project"
cp /home/deploy/apps/adts_demo/deploy/adt_demo.conf /etc/nginx/sites-available/adt.codingpains
if [ -f /etc/nginx/sites-enabled/adt.codingpains ]; then
    echo "-- Link already exists"
else
    ln -s /etc/nginx/sites-available/adt.codingpains /etc/nginx/sites-enabled/adt.codingpains
fi

service nginx restart

exit 0;
