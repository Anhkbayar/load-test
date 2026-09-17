import { check, sleep } from 'k6';
import http from 'k6/http';

export const options = {
  vus: 30, duration: "1m",
  thresholds: {
    http_req_duration: ['p(95)<344'],
    http_req_failed: ['rate<0.001'], // SLO: error rate < 0.1%
  },

};

export default function () {
  const res = http.get('https://test.k6.io');
  check(res, { 'status 200 байна': (r) => r.status === 200 });
  sleep(1);
}
