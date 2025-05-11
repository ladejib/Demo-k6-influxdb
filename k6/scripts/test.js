import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  ext: {
    influxdb: {
      url: "http://influxdb:8086/k6db",
      username: "k6",
      password: "k6pass",
      insecure: true,       // For HTTP (not HTTPS)
      timeout: "60s",       // HTTP timeout for writes
      concurrentWrites: 3,  // Reduce concurrent writes
      tagToString: true,    // Can help with performance
      tags: {
        test_type: "load"
      }
    }
  },
  stages: [
    { duration: '30s', target: 5 },
    { duration: '1m', target: 10 },
    { duration: '30s', target: 0 }
  ],
  noConnectionReuse: true
};

const TEST_URL = 'http://test.k6.io';

export default function () {
  const res = http.get(TEST_URL);
  
  check(res, {
    'status was 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(0.1);
}