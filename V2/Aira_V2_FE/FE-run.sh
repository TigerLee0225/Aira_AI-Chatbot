# Docker image creation
docker-compose -f docker-compose.frontend.yml build --no-cache

# Docker compose container run
docker-compose -f docker-compose.frontend.yml up -d