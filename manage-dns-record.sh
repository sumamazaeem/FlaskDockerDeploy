#!/bin/bash

# Load environment variables from .env file
set -o allexport
source /app/.env
set +o allexport

# Debugging: Print environment variables
echo "CLOUDFLARE_API_URL: $CLOUDFLARE_API_URL"
echo "ZONE_ID: $ZONE_ID"
echo "CLOUDFLARE_DNS_RECORD_TYPE: $CLOUDFLARE_DNS_RECORD_TYPE"
echo "CLOUDFLARE_IP_ADDRESS: $CLOUDFLARE_IP_ADDRESS"
echo "DOMAIN_NAME: $DOMAIN_NAME"

# Validate necessary environment variables
: "${CLOUDFLARE_API_URL:?Need to set CLOUDFLARE_API_URL}"
: "${ZONE_ID:?Need to set ZONE_ID}"
: "${CLOUDFLARE_DNS_RECORD_TYPE:?Need to set CLOUDFLARE_DNS_RECORD_TYPE}"
: "${CLOUDFLARE_IP_ADDRESS:?Need to set CLOUDFLARE_IP_ADDRESS}"
: "${DOMAIN_NAME:?Need to set DOMAIN_NAME}"

# Get existing DNS records
echo "Fetching existing DNS records for $DOMAIN_NAME..."
RESPONSE=$(curl --request GET \
  --url "${CLOUDFLARE_API_URL}/zones/${ZONE_ID}/dns_records?name=${DOMAIN_NAME}&type=${CLOUDFLARE_DNS_RECORD_TYPE}" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer ${DNS_CLOUDFLARE_API_TOKEN}")

echo "Raw Response from Cloudflare API:"
echo "$RESPONSE"

# Validate JSON response
if ! echo "$RESPONSE" | jq -e . > /dev/null 2>&1; then
    echo "Error: Invalid JSON response from Cloudflare API."
    exit 1
fi
echo "Valid JSON response."

# Parse the response to check if the record exists and get its ID
RECORD_ID=$(echo "$RESPONSE" | jq -r '.result[] | select(.name == "'$DOMAIN_NAME'") | .id')

if [ -n "$RECORD_ID" ]; then
    echo "DNS record exists. Updating with new IP address..."
    UPDATE_RESPONSE=$(curl --request PUT \
      --url "${CLOUDFLARE_API_URL}/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
      --header "Content-Type: application/json" \
      --header "Authorization: Bearer ${DNS_CLOUDFLARE_API_TOKEN}" \
      --data '{
        "type": "'$CLOUDFLARE_DNS_RECORD_TYPE'",
        "name": "'$DOMAIN_NAME'",
        "content": "'$CLOUDFLARE_IP_ADDRESS'",
        "ttl": 3600,
        "proxied": false
      }')
    echo "Response from Cloudflare API on update: $UPDATE_RESPONSE"
else
    echo "No DNS record found. Creating a new record..."
    CREATE_RESPONSE=$(curl --request POST \
      --url "${CLOUDFLARE_API_URL}/zones/${ZONE_ID}/dns_records" \
      --header "Content-Type: application/json" \
      --header "Authorization: Bearer ${DNS_CLOUDFLARE_API_TOKEN}" \
      --data '{
        "type": "'$CLOUDFLARE_DNS_RECORD_TYPE'",
        "name": "'$DOMAIN_NAME'",
        "content": "'$CLOUDFLARE_IP_ADDRESS'",
        "ttl": 3600,
        "proxied": false
      }')
    echo "Response from Cloudflare API on creation: $CREATE_RESPONSE"
fi
