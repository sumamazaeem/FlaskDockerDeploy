# Use official Python slim image as base image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies including netcat
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    default-mysql-client \
    curl \
    wget \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the project files into the working directory
COPY app app
COPY migrations migrations
COPY app.py config.py boot.sh gunicorn_config.py ./

# Ensure boot.sh is executable
RUN chmod +x boot.sh

# Set environment variables
ENV FLASK_APP=app.py

# Expose port 5000 for the Flask application
EXPOSE 5000

# Define the entry point to run the application with gunicorn
ENTRYPOINT ["./boot.sh"]
