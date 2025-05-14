#!/bin/bash
# Save this as check-influxdb.sh and make executable with: chmod +x check-influxdb.sh

echo "=== InfluxDB Diagnostics Tool ==="

echo -e "\n[1] Checking InfluxDB container status..."
docker ps -f name=influxdb --format "{{.ID}}\t{{.Status}}\t{{.Names}}"

echo -e "\n[2] Checking InfluxDB memory usage..."
docker stats influxdb --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo -e "\n[3] Testing InfluxDB connection..."
if curl -s http://localhost:8086/ping > /dev/null; then
  echo "InfluxDB ping successful!"
else
  echo "InfluxDB ping failed!"
fi

echo -e "\n[4] Checking databases..."
curl -s -G http://localhost:8086/query --data-urlencode "q=SHOW DATABASES" -u admin:admin123 | \
  grep -o '"name":"[^"]*"' | cut -d'"' -f4 | while read -r db; do
    echo "  - $db"
done

echo -e "\n[5] Checking measurements in k6db..."
curl -s -G http://localhost:8086/query --data-urlencode "db=k6db" --data-urlencode "q=SHOW MEASUREMENTS" -u admin:admin123 | \
  grep -o '"name":"[^"]*"' | cut -d'"' -f4 | while read -r measurement; do
    echo "  - $measurement"
done

echo -e "\n[6] Sample data count in k6db..."
curl -s -G http://localhost:8086/query --data-urlencode "db=k6db" --data-urlencode "q=SELECT count(*) FROM http_reqs" -u admin:admin123 | \
  grep -o '"values":\[\[[^]]*\]\]' | cut -d'[' -f3 | cut -d']' -f1 | while read -r count; do
    echo "  - http_reqs count: $count"
done


echo -e "\n[7] InfluxDB write throughput (last 5 minutes)..."
curl -s -G http://localhost:8086/query --data-urlencode "db=_internal" \
  --data-urlencode "q=SELECT non_negative_derivative(mean(writeReq), 1m) as write_throughput FROM \"monitor\".\"write\" WHERE time > now() - 5m GROUP BY time(30s)" \
  -u admin:admin123 | grep -o '"values":\[\[.*\]\]' | sed 's/"values":\[\[//g' | sed 's/\]\]//g' | tr ',' '\n' | while read -r point; do
    echo "  - $point writes/min"
done

echo -e "\n[8] InfluxDB container logs (last 10 lines)..."
docker logs influxdb --tail 10


echo -e "\n[6] Sample data count in k6db..."
curl -s -G http://localhost:8086/query --data-urlencode "db=k6db" --data-urlencode "q=show tables" -u admin:admin123 | \
  grep -o '"values":\[\[[^]]*\]\]' | cut -d'[' -f3 | cut -d']' -f1 | while read -r count; do
    echo "  - http_reqs count: $count"
done
echo -e "\n=== Diagnostics Complete ==="