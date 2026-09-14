import { check, sleep } from 'k6';
import http from 'k6/http';

export const options = {
  vus: __ENV.VUS ? parseInt(__ENV.VUS) : 5,
  duration: __ENV.TEST_DURATION || '30s',
};

export default function () {
  const res = http.get(__ENV.TARGET_URL || 'https://test.k6.io');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
