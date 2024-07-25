#!/bin/bash

cat <<EOF > /etc/nginx/nginx.conf.template
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name ${WEBSITE_URL};  # Use environment variable for the domain name

        location / {
            proxy_pass http://${FLASK_APP_SERVICE_HOST}:${FLASK_APP_SERVICE_PORT};
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }

    server {
        listen 443 ssl;
        server_name ${WEBSITE_URL};

        ssl_certificate /etc/letsencrypt/live/${WEBSITE_URL}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${WEBSITE_URL}/privkey.pem;
        include /etc/letsencrypt/options-ssl-nginx.conf;
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

        location / {
            proxy_pass http://${FLASK_APP_SERVICE_HOST}:${FLASK_APP_SERVICE_PORT};
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF
