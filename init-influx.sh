#!/bin/bash
set -e

# Function to initialize InfluxDB
init_influxdb() {
  # Wait for InfluxDB to be ready
  while ! influx -execute 'SHOW DATABASES'; do
    sleep 1
    echo "Waiting for InfluxDB to be ready..."
  done

  # Create database and user
  influx -execute "CREATE DATABASE k6db"
  influx -execute "CREATE USER k6 WITH PASSWORD 'k6pass'"
  influx -execute "GRANT ALL ON k6db TO k6"
  echo "InfluxDB initialization complete!"
}


# Run initialization in background
init_influxdb &

# Keep the container running
exec /entrypoint.sh influxd