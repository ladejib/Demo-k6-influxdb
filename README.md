
# k6 Performance Testing Infrastructure
This repository contains a Docker-based infrastructure for running k6 load tests with metrics storage in InfluxDB and visualization in Grafana.

The infrastructure consists of three main components:

### k6 - An open-source load testing tool that makes performance testing easy and productive
### InfluxDB - A time series database optimized for high-write-volume time series data
### Grafana - A visualization and analytics platform for metrics and logs


Docker and Docker Compose installed on your system

Basic understanding of load testing concepts

At least 4GB of available RAM for the containers


## Quick Start
### Clone this repository:

bashgit clone <repository-url>

bashchmod +x init-influx.sh check-influxdb.sh

### run
sh start-service.sh

### View the results in Grafana:

Open http://localhost:3000 in your browser

Login with username: admin and password: admin

Navigate to the "k6 Load Testing Results" dashboard


## Troubleshooting
If you encounter issues:

### Run the diagnostics script:

bash./check-influxdb.sh

### Check container logs:

bashdocker-compose logs influxdb

docker-compose logs k6

### Common issues and solutions:

#### "Couldn't write stats" or "timeout" errors:

Increase timeouts in the k6 script

Reduce the test load

Allocate more resources to InfluxDB


#### "The flush operation took higher than the expected..." warnings:

Increase the flushInterval and pushInterval in k6 script

Reduce the amount of data being collected

Optimize InfluxDB write parameters


#### No data in Grafana:

Ensure InfluxDB is running and configured correctly

Check InfluxDB connection from Grafana

Verify data is being written to InfluxDB



