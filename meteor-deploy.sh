#!/bin/sh
# IP or URL of the server you want to deploy to
APP_HOST=host

#USERNAME OF THE SERVER
ROOT="root"

# If you want a different ROOT_URL, when using a load balancer for instance, set it here
ROOT_URL='test.example.com'

# What's your project's Git repo?
GIT_URL="git repo"


#If you have an external service, such as Google SMTP, set this
#MAIL_URL=smtp://USERNAME:PASSWORD@smtp.googlemail.com:465

# What's your app name (must be same as folder of git )?
APP_NAME="name of app" # must be same as git folder

# Kill the forever and node processes, and deletes the bundle directory and tar file prior to deploying
FORCE_CLEAN=true

#PORT NO ON WHICH OUR APP WILL BE RUNNING
PORT=4001

#URL OF THE MONGO
MONGO_URL=mongodb://localhost:27017/dbname

# No Need to change following

Meteor_CMD="meteor"

SSH_HOST=$ROOT@$APP_HOST

APP_DIR="/apps/meteor"


#variables for NGINX VHOST

# Variables
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
SERVER_NAME=$3

PROXY_PASS='http://127.0.0.1':$PORT
NGINX_HTTP_UPGRADE='\$http_upgrade'
NGINX_REMOTE_ADDR='\$remote_addr'

if [ -z "$ROOT_URL" ]; then
	ROOT_URL=http://$APP_HOST
fi


if [ -z "$MONGO_URL" ]; then
	MONGO_URL=mongodb://localhost:27017/f7db
fi

if [ -z "$BIND_IP" ]; then
	BIND_IP='0.0.0.0'
fi

if [ -z "$PORT" ]; then
	PORT=80
fi


SETUP_NGINX(){
# Variables
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
SERVER_NAME=$3

PROXY_PASS='http://127.0.0.1':$PORT
NGINX_HTTP_UPGRADE='\$http_upgrade'
NGINX_REMOTE_ADDR='\$remote_addr'
ssh $SSH_OPT $SSH_HOST <<ENDSHH
# Create nginx config file
{
 echo    server {;
  echo listen                *:80";";

 echo  server_name           $ROOT_URL";";

 echo  access_log            /var/log/nginx/$APP_NAME.access.log";";
  echo error_log             /var/log/nginx/$APP_NAME.error.log";";

 echo  location / { ;
 echo    proxy_pass $PROXY_PASS";";
 echo    proxy_http_version 1.1 ";";
 echo    proxy_set_header Upgrade $NGINX_HTTP_UPGRADE";";
 echo    proxy_set_header Connection 'upgrade'";";
 echo    proxy_set_header X-Forwarded-For $NGINX_REMOTE_ADDR";";

 echo  };

echo    }



} >> $NGINX_AVAILABLE_VHOSTS/$APP_NAME
touch /var/log/nginx/$APP_NAME.access.log
touch /var/log/nginx/$APP_NAME.error.log

ln -s $NGINX_AVAILABLE_VHOSTS/$APP_NAME $NGINX_ENABLED_VHOSTS/$APP_NAME
/etc/init.d/nginx stop
/etc/init.d/nginx start

ENDSHH
}

SETUP="

echo Setting up server;
echo installing nginx;
sudo apt-get update;
sudo apt-get install nginx;
sudo apt-get install software-properties-common;
sudo add-apt-repository ppa:chris-lea/node.js;
sudo apt-get -qq update;
echo installing GIT, mongodb;
sudo apt-get install git mongodb;
echo inatalling node;
sudo apt-get install nodejs;
node --version;
installing forever npm package;

sudo npm install -g forever;
echo installing meteor latest distribution;

curl https://install.meteor.com | /bin/sh;
"

DEPLOY="

echo Deploying Meteor app please wait......;
cd $APP_DIR;
cd $APP_NAME;
echo Updating codebase;
sudo git fetch origin;
sudo git checkout master;
sudo git pull origin master;
ls;
if [ "$FORCE_CLEAN" == "true" ]; then
    echo Killing forever and node;
     forever stop $APP_NAME;
    echo Cleaning bundle files;
    sudo rm -rf ../bundle > /dev/null 2>&1;
fi;
echo Creating new bundle. This may take a few minutes. Please have some patience;
sudo meteor build /apps/running/$APP_NAME;
cd /apps/running/$APP_NAME;
sudo tar -zxvf $APP_NAME.tar.gz;

export MONGO_URL=$MONGO_URL;
export ROOT_URL=$ROOT_URL;
cd bundle/programs/server;
npm install;
cd ../..;
if [ -n "$MAIL_URL" ]; then
    export MAIL_URL=$MAIL_URL;
fi;
export BIND_IP=$BIND_IP;
export PORT=$PORT;
"

DEPLOY="$DEPLOY
echo Starting forever;
  PORT=$PORT MONGO_URL=$MONGO_URL ROOT_URL=http://$ROOT_URL  forever start --uid $APP_NAME -a main.js;

";

SETUPProject=" echo ============Setting up project ====================;
    echo creating project directory;
    sudo mkdir -p $APP_DIR;
    cd $APP_DIR;
    echo cloning repo;
    sudo git clone $GIT_URL;
";



case "$1" in
setup)
    if [ "$2" == "server" ]; then
	    ssh $SSH_OPT $SSH_HOST $SETUP
    fi
    if [ "$2" == "project" ]; then
	    ssh $SSH_OPT $SSH_HOST $SETUPProject
    fi
    if [ "$2" == "nginx" ]; then
        SETUP_NGINX
    fi

	;;
deploy)
	ssh $SSH_OPT $SSH_HOST $DEPLOY
	;;

*)
	cat <<ENDCAT
Available actions:
setup server  - Install a meteor environment on a fresh Ubuntu server Required Only Once
setup project - Initialize directories for meteor deployment Required Only Once for each project
setup nginx - Setup nginx vhost for our application requires only once for each URL or domain name
deploy  - Deploy the app to the server
ENDCAT
	;;
esac


