#!/bin/bash
set -e

# Log in to Amazon ECR in the ap-northeast-2 region
aws ecr get-login-password --region ap-northeast-2 | \
  docker login --username AWS --password-stdin 730335258114.dkr.ecr.ap-northeast-2.amazonaws.com

# Create (or reuse) a Buildx builder instance
docker buildx create --use || true

# Build the FE image for both linux/amd64 and linux/arm64 and push directly to ECR.
# This tags the image locally as "aira-fe:latest" and with the full ECR URI.
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t 730335258114.dkr.ecr.ap-northeast-2.amazonaws.com/aira/fe:latest \
  --push .