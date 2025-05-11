import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  ext: {
    influxdb: {
      url: "http://influxdb:8086/k6db",
      username: "k6",
      password: "k6pass",
      insecure: true,
      // Add these timeout settings
      timeout: "60s",       // HTTP timeout for writes
      concurrentWrites: 3,  // Reduce concurrent writes
      tagToString: true,    // Can help with performance
      tags: {
        test_type: "load"
      }
    }
  },
  // Reduced initial load to verify connection works
  stages: [
    { duration: '15s', target: 2 },   // Start with fewer users
    { duration: '30s', target: 5 },   // Gradually increase
    { duration: '15s', target: 0 }    // Ramp down
  ],
  // Add a batch configuration to control data flow
  batchPerHost: 10,  // Send data in smaller batches
  // Define thresholds for success criteria
  thresholds: {
    'http_req_duration': ['p(95)<500'],  // 95% of requests should be below 500ms
    'http_req_failed': ['rate<0.01'],    // Less than 1% of requests should fail
  },
  noConnectionReuse: true
};

const TEST_URL = 'http://test.k6.io';

export default function () {
  // Add retry logic for robustness
  let response;
  let retries = 3;
  
  while (retries > 0) {
    response = http.get(TEST_URL);
    
    // If successful, break the retry loop
    if (response.status === 200) {
      break;
    }
    
    retries--;
    if (retries > 0) {
      console.log(`Request failed with status ${response.status}, retrying...`);
      sleep(1);
    }
  }
  
  // Perform checks
  check(response, {
    'status was 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  // Increased sleep time slightly to reduce request rate
  sleep(0.3);
}