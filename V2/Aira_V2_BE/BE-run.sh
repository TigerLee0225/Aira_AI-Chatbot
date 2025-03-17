# Docker compose image creation
docker-compose -f docker-compose.backend.yml build --no-cache

# Docker compose container run
docker-compose -f docker-compose.backend.yml up -d