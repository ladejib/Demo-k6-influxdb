docker-compose down -v
docker volume prune -f
docker network prune -f

docker-compose up -d influxdb

# Wait for initialization (30 seconds)
sleep 30

docker-compose up -d grafana
