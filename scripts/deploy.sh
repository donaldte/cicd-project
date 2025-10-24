#!/bin/bash

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Pull the latest images
docker-compose -f docker-compose.prod.yml pull

# Stop and remove existing containers
docker-compose -f docker-compose.prod.yml down

# Start new containers
docker-compose -f docker-compose.prod.yml up -d

# Clean up unused images
docker image prune -f