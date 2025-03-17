# Docker compose container down
docker-compose -f docker-compose.backend.yml down

# Docker compose db remove
docker-compose -f docker-compose.backend.yml down --volumes

# Docker compose image remove
docker-compose -f docker-compose.backend.yml down --rmi local