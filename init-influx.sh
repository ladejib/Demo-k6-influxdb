
#!/bin/bash
set -e

# Wait for InfluxDB to be ready
echo "Waiting for InfluxDB to start..."
for i in {1..30}; do
  if curl -s -f http://localhost:8086/ping >/dev/null; then
    echo "InfluxDB is up and running"
    break
  fi
  echo "Waiting for InfluxDB... ($i/30)"
  sleep 1
done

# Create database and users with explicit authorization
echo "Creating database and users..."
influx -execute "CREATE DATABASE k6db WITH DURATION 30d"
influx -execute "CREATE USER k6 WITH PASSWORD 'k6pass'"
influx -execute "GRANT ALL ON k6db TO k6"

# Create retention policy with appropriate settings
echo "Setting up retention policy..."
influx -execute "CREATE RETENTION POLICY \"k6_retention\" ON \"k6db\" DURATION 30d REPLICATION 1 DEFAULT"

# Creating continuous queries for downsampling if needed
influx -execute "CREATE CONTINUOUS QUERY \"cq_30m\" ON \"k6db\" BEGIN SELECT mean(\"value\") AS \"mean_value\" INTO \"k6db\".\"k6_retention\".\"downsampled_metrics\" FROM \"k6db\".\"k6_retention\"./.*/ GROUP BY time(30m), * END"

echo "InfluxDB initialization completed successfully"