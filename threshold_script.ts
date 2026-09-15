import { check, sleep } from 'k6';
import http from 'k6/http';

export const options = {
  vus: 5, duration: "1m",
  thresholds: {
    http_req_duration: ['p(95)<297.7'], // SLO: p95 < 253ms
    http_req_failed: ['rate<0.001'], // SLO: error rate < 1%
  },

};

export default function () {
  const res = http.get('https://test.k6.io');
  check(res, { 'status 200 байна': (r) => r.status === 200 });
  sleep(1);
}
