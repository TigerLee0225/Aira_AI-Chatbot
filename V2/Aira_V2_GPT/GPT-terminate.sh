# Docker compose container down
docker-compose -f docker-compose.gpt.yml down

# Docker compose db remove
docker-compose -f docker-compose.gpt.yml down --volumes

# Docker compose image remove
docker-compose -f docker-compose.gpt.yml down --rmi local