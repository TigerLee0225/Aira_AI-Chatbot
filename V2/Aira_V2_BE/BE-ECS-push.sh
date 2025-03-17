#!/bin/bash
set -e

# Log in to Amazon ECR
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 730335258114.dkr.ecr.ap-northeast-2.amazonaws.com

# Create (or reuse) a buildx builder instance
docker buildx create --use || true

# Build the image for both linux/amd64 and linux/arm64 and push it directly to ECR.
# This command tags the image locally as "aira-be:latest" and also tags it with your full ECR URI.
# The --push flag ensures that a multi-architecture manifest is published to ECR.
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t 730335258114.dkr.ecr.ap-northeast-2.amazonaws.com/aira/be:latest \
  --push .