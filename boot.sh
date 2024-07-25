#!/bin/bash
# This script is used to boot a Docker container

# Function to wait for a service to be ready
wait_for_service() {
  local host="$1"
  local port="$2"
  echo "Waiting for $host:$port to be ready..."
  while ! nc -z "$host" "$port"; do
    >&2 echo "Waiting for $host:$port to be ready..."
    sleep 1
  done
  >&2 echo "$host:$port is up."
}

# Parameters: host and port of the database
DB_HOST="db"
DB_PORT="3306"

# Wait for the database to be ready
wait_for_service "$DB_HOST" "$DB_PORT"

# Apply database migrations
flask db upgrade

# Start Gunicorn server
exec gunicorn -c gunicorn_config.py 'app:create_app()'
