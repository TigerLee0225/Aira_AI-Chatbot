# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Update the keyring first to ensure repository signatures are valid
RUN apt-get update && apt-get install -y --no-install-recommends \
    debian-archive-keyring \
    && rm -rf /var/lib/apt/lists/*

# Fix common issues with apt-get in minimal images
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install debugging utilities
RUN apt-get update && apt-get install -y \
    iputils-ping \
    default-mysql-client \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Install system dependencies required by some Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application source code into the container
COPY src .

# Expose port 9000
EXPOSE 9000

# Run the FastAPI app with uvicorn, assuming main.py defines app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "9000"]