#!/bin/bash

env

# Load environment variables from .env file
if [ -f /app/.env ]; then
    . /app/.env
else
    echo ".env file not found!"
    exit 1
fi

# Print specific variables
echo "WEBSITE_URL: $WEBSITE_URL"
echo "LETSENCRYPT_EMAIL: $LETSENCRYPT_EMAIL"
echo "DNS_PROVIDER: $DNS_PROVIDER"
echo "DNS_CLOUDFLARE_API_TOKEN: $DNS_CLOUDFLARE_API_TOKEN"
echo "CLOUDFLARE_API_URL: $CLOUDFLARE_API_URL"
echo "CLOUDFLARE_DNS_RECORD_TYPE: $CLOUDFLARE_DNS_RECORD_TYPE"
echo "CLOUDFLARE_IP_ADDRESS: $CLOUDFLARE_IP_ADDRESS"
echo "ZONE_ID: $ZONE_ID"

# Ensure required environment variables are set
: "${WEBSITE_URL:?Need to set WEBSITE_URL}"
: "${LETSENCRYPT_EMAIL:?Need to set LETSENCRYPT_EMAIL}"
: "${DNS_PROVIDER:?Need to set DNS_PROVIDER}"
: "${DNS_CLOUDFLARE_API_TOKEN:?Need to set DNS_CLOUDFLARE_API_TOKEN}"
: "${ZONE_ID:?Need to set ZONE_ID}"
echo "Environment variables are set. Proceeding with the script."

# Ensure DOMAIN_NAME is set correctly
DOMAIN_NAME=$(echo $WEBSITE_URL | sed 's/^www\.//')
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: DOMAIN_NAME is empty. Check WEBSITE_URL."
    exit 1
fi
echo "Using DOMAIN_NAME: $DOMAIN_NAME"
echo "Using WEBSITE_URL: $WEBSITE_URL"

# Delete the flag file if it already exists
if [ -f /data/letsencrypt/certbot_done.flag ]; then
    echo "Removing existing certbot_done.flag file..."
    rm /data/letsencrypt/certbot_done.flag
    echo "certbot_done.flag removed."
else
    echo "No existing certbot_done.flag file found. Nothing to remove."
fi

# Ensure the directory is writable and exists
echo "Creating directory /data/letsencrypt/ if it does not exist..."
mkdir -p /data/letsencrypt/
echo "Directory /data/letsencrypt/ created or already exists."

# Write Cloudflare credentials
echo "Writing Cloudflare API token to /data/letsencrypt/cloudflare_credentials.ini..."
echo "dns_cloudflare_api_token = ${DNS_CLOUDFLARE_API_TOKEN}" > /data/letsencrypt/cloudflare_credentials.ini
chmod 600 /data/letsencrypt/cloudflare_credentials.ini
echo "Cloudflare credentials written and permissions set to 600."

# Function to manage DNS records
manage_dns_record() {
    # Execute the manage-dns-record.sh script
    echo "Managing DNS records..."
    /app/manage-dns-record.sh
}

# Attempt to create or update the A record for the subdomain
manage_dns_record

# Wait for DNS propagation
echo "Waiting for DNS propagation..."
sleep 30

# Generate the SSL certificate using certbot
echo "Requesting SSL certificate using certbot..."
certbot certonly --dns-cloudflare --dns-cloudflare-credentials /data/letsencrypt/cloudflare_credentials.ini \
  --dns-cloudflare-propagation-seconds 60 --email ${LETSENCRYPT_EMAIL} -d ${DOMAIN_NAME} --non-interactive --agree-tos

# Check if the certificate request was successful
if [ $? -eq 0 ]; then
    echo "SSL certificate successfully requested and obtained."
    # Create the flag file to indicate success
    touch /data/letsencrypt/certbot_done.flag
    echo "Flag file created: /data/letsencrypt/certbot_done.flag"
else
    echo "Failed to obtain SSL certificate. Exiting."
    exit 1
fi

# Keep the container running
echo "Initialization complete. Keeping container alive..."
while true; do
    sleep 3600  # Sleep for 1 hour
    # You can add periodic checks or maintenance tasks here if needed
done
