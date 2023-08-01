#!/bin/bash

SERVER_IP=
MANUAL="Usage: $0 [-i server_ip]"

# curl ifconfig.me 이용해서 ip 자동입력

while getopts "i:" option; do
    case $option in
        i)
            SERVER_IP=$OPTARG
            ;;
        *)
            echo $MANUAL
            exit 1
            ;;
    esac
done    

if [ -z $SERVER_IP ]; then
    SERVER_IP=$(curl ifconfig.me)
    # exit 1
fi


# nginx installation
echo "Install nginx"
sudo apt install -y nginx

# nginx configuration file 
echo "Create nginx config"
sudo sh -c "cat > /etc/nginx/sites-available/django <<EOF
server {
	listen 80;
	server_name $SERVER_IP;

	location / {
		proxy_pass http://127.0.0.1:8000;
		proxy_set_header Host \\\$host;
		proxy_set_header X-Real-IP \\\$remote_addr;
	}
}
EOF"

# symlink
echo "Create symlink"
TARGET_CONF=/etc/nginx/sites-enabled/django

if [ -e $TARGET_CONF ]; then
    ehco "Remove symlink"
    sudo rm $TARGET_CONF
fi

sudo ln -s /etc/nginx/sites-available/django $TARGET_CONF

# nginx restart
echo "Restart nginx"
sudo systemctl restart nginx


