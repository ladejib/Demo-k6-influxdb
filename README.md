
docker-compose down -v  # This removes ALL data
docker volume prune -f  # Clean up any dangling volumes
docker-compose up -d influxdb
docker-compose up -d grafana
docker-compose run --rm k6 run /scripts/test.js
docker-compose run --rm k6 run --verbose --out influxdb=http://influxdb:8086/k6db  /scripts/test.js
docker-compose exec influxdb influx -username k6 -password k6pass -database k6db -execute 'SHOW MEASUREMENTS'
docker-compose exec influxdb influx -username k6 -password k6pass -database k6db   -execute 'SELECT * FROM http_reqs LIMIT 5'
