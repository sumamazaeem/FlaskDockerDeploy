# FlaskDockerDeploy : Containers and Deployment

## Description
This is the repository that contains code to deploy the python flask application

## Prerequisites
- Docker installed (https://docs.docker.com/get-docker/)
- Docker Compose installed (https://docs.docker.com/compose/install/)

---

## Part 1: Running with Docker Compose

### Step 1: Clone the Repository
```sh
git clone https://github.com/sumamazaeem/FlaskDockerDeploy.git
cd FlaskDockerDeploy

```

### Make sure that you have the .env file


```.env
# Database configuration
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=your_database_name
MYSQL_USER=your_database_user
MYSQL_PASSWORD=your_database_password
DATABASE_URL=mysql+pymysql://your_database_user:your_database_password@db/your_database_name

# Flask application configuration
SECRET_KEY=your_flask_secret_key

# Email configuration
EMAIL=your_email@example.com

# Website and Flask application configuration
WEBSITE_URL=your-website-url.com
FLASK_IMAGE_REPO_URL=your_account_id.dkr.ecr.your-region.amazonaws.com/your-flask-repo:latest
CERTBOT_INIT_IMAGE_REPO_URL=your_account_id.dkr.ecr.your-region.amazonaws.com/your-certbot-repo:latest
NGINX_IMAGE_REPO_URL=nginx:latest
MARIADB_IMAGE_REPO_URL=mariadb:latest

# DNS and Cloudflare configuration
DNS_PROVIDER=cloudflare
FLASK_APP_SERVICE_HOST=your_flask_app_service_host
FLASK_APP_SERVICE_PORT=your_flask_app_service_port
DNS_CLOUDFLARE_API_TOKEN=your_cloudflare_api_token
CLOUDFLARE_API_URL=https://api.cloudflare.com/client/v4
CLOUDFLARE_DNS_RECORD_TYPE=A
CLOUDFLARE_IP_ADDRESS=your_ip_address
ZONE_ID=your_zone_id
DOMAIN_NAME=your-domain-name.com
A_RECORD_TYPE=A

# AWS ECR configuration
AWS_ACCESS_KEY_ID=your_aws_access_key_id
AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key
AWS_ACCOUNT_ID=your_aws_account_id
```

# Environment Variables

## Database Configuration
- `MYSQL_ROOT_PASSWORD`: The root password for your MySQL database. (e.g., `exampleRootPassword123`)
- `MYSQL_DATABASE`: The name of the MySQL database to be used. (e.g., `exampleDatabase`)
- `MYSQL_USER`: The MySQL database user with privileges to access the specified database. (e.g., `exampleUser`)
- `MYSQL_PASSWORD`: The password for the specified MySQL database user. (e.g., `exampleUserPassword123`)
- `DATABASE_URL`: The URL used by your application to connect to the MySQL database. (e.g., `mysql+pymysql://exampleUser:exampleUserPassword123@db/exampleDatabase`)

## Flask Application Configuration
- `SECRET_KEY`: A secret key used by Flask for session management and other security-related tasks. (e.g., `mySuperSecretKey2024`)

## Email Configuration
- `EMAIL`: The email address used for notifications, such as from Let's Encrypt. (e.g., `user@example.com`)

## Website and Flask Application Configuration
- `WEBSITE_URL`: The URL of your website where the Flask application will be hosted. (e.g., `example-website.com`)
- `FLASK_IMAGE_REPO_URL`: The URL of your Flask application Docker image repository. (e.g., `123456789012.dkr.ecr.us-east-1.amazonaws.com/my-flask-app:latest`)
- `CERTBOT_INIT_IMAGE_REPO_URL`: The URL of the Certbot initialization Docker image repository. (e.g., `123456789012.dkr.ecr.us-east-1.amazonaws.com/my-certbot-init:latest`)
- `NGINX_IMAGE_REPO_URL`: The URL of your NGINX Docker image repository. (e.g., `nginx:latest`)
- `MARIADB_IMAGE_REPO_URL`: The URL of your MariaDB Docker image repository. (e.g., `mariadb:latest`)

## DNS and Cloudflare Configuration
- `DNS_PROVIDER`: The DNS provider used, in this case, Cloudflare. (e.g., `cloudflare`)
- `FLASK_APP_SERVICE_HOST`: The hostname for the Flask application service within your Docker network. (e.g., `flask-service`)
- `FLASK_APP_SERVICE_PORT`: The port number on which the Flask application service runs. (e.g., `5000`)
- `DNS_CLOUDFLARE_API_TOKEN`: The API token for authenticating with Cloudflare. (e.g., `your-cloudflare-api-token`)
- `CLOUDFLARE_API_URL`: The base URL for the Cloudflare API. (e.g., `https://api.cloudflare.com/client/v4`)
- `CLOUDFLARE_DNS_RECORD_TYPE`: The type of DNS record to create/update (A record in this case). (e.g., `A`)
- `CLOUDFLARE_IP_ADDRESS`: The IP address associated with the A record for your domain. (e.g., `192.168.1.1`)
- `ZONE_ID`: The Zone ID in Cloudflare for your domain. (e.g., `exampleZoneId123456`)
- `DOMAIN_NAME`: The domain name for your website. (e.g., `example-website.com`)
- `A_RECORD_TYPE`: The type of DNS A record. (e.g., `A`)

## AWS ECR Configuration
- `AWS_ACCESS_KEY_ID`: Your AWS Access Key ID for authentication with AWS services. (e.g., `AKIAEXAMPLEACCESSKEY`)
- `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Access Key for authentication with AWS services. (e.g., `exampleSecretAccessKey1234`)
- `AWS_ACCOUNT_ID`: Your AWS account ID. (e.g., `123456789012`)

Then use the command to export and echo to check the variables are correclty defined:
```sh
export $(grep -v '^#' .env | xargs)
while read -r line || [ -n "$line" ]; do [ -z "$line" ] || [ "${line#\#}" != "$line" ] || (echo "Exporting: $line"; export "$line"); done < .env
```

### Docker Compose Command

```sh
docker compose up --build
```

This command will build the Docker images if they don't already exist and then start up all the services defined in the `docker-compose.yml` file

### Access the Website

```
https://{WEBSITE_URL}
```



Then access the website from the web. For cleaning, use the command `docker compose down`



## Part 2: Deploying with Docker Stack

### Step 1: Initialize Docker Swarm

If you haven't already, initialize Docker Swarm on your machine or server.

```sh
docker swarm init
```



### Step 2: Export the Env variables in the shell

```sh
export $(grep -v '^#' .env | xargs)
while read -r line || [ -n "$line" ]; do [ -z "$line" ] || [ "${line#\#}" != "$line" ] || (echo "Exporting: $line"; export "$line"); done < .env
```



### Step 3: Deploy the Stack

Deploy the stack using the docker-stack.yml file.

```sh
docker stack deploy -c docker-stack.yml FlaskDockerDeploy
```




### Step 4: Verify the Deployment

Check the status of the deployed services.

```sh
docker stack services FlaskDockerDeploy
```



### Step 5: Scale the Services
Scale the services as required.

```sh
docker service scale FlaskDockerDeploy_service_name=number_of_replicas
```



### Step 6: Remove the Stack

If you want to tear down the stack, you can do so by running:

```sh
docker stack rm FlaskDockerDeploy
```

other useful commands:

```
docker stack deploy -c docker-stack.yml FlaskDockerDeploy
docker stack services FlaskDockerDeploy
docker stack ps FlaskDockerDeploy
docker service logs -f FlaskDockerDeploy_flask-app
docker service scale FlaskDockerDeploy_flask-app=5
docker stack rm FlaskDockerDeploy
docker stack ls
docker stack inspect FlaskDockerDeploy
docker service ls
docker service ps FlaskDockerDeploy_flask-app

```
