# load-test

## Суурь хэмжилт

### Туршилтын тохиргоо

- **Target:** `https://test.k6.io`
- **Virtual Users (VUs):** 5
- **Duration:** 30 секунд
- **Total iterations:** 115
- **Total HTTP requests:** 230

## Үндсэн үзүүлэлтүүд

### 1. HTTP Request Duration

`http_req_duration` нь HTTP request-ийн нийт хариу өгөх хугацааг миллисекундээр харуулна.

| Metric        |         Value |
| ------------- | ------------: |
| Average (avg) | **142.15 ms** |
| p90           | **228.43 ms** |
| p95           | **229.56 ms** |
| Minimum       |      54.17 ms |
| Maximum       |     238.73 ms |

Дундаж request duration нь **142.15 ms** байна. Request-үүдийн 90% нь **228.43 ms**-ээс бага буюу тэнцүү, 95% нь **229.56 ms**-ээс бага буюу тэнцүү хугацаанд дууссан.

### 2. HTTP Requests / Throughput

`http_reqs` нь нийт HTTP request болон секундэд боловсруулсан request-ийн тоог харуулна.

| Metric         |                 Value |
| -------------- | --------------------: |
| Total requests |               **230** |
| Throughput     | **7.60 requests/sec** |

30 секундын турш нийт **230 HTTP request** илгээгдсэн бөгөөд throughput нь **7.60 requests/sec** байсан.

### 3. HTTP Request Failed / Error Rate

`http_req_failed` нь амжилтгүй болсон HTTP request-ийн хэмжээг харуулна. Энэ нь лекцийн **POFOD (Probability of Failure on Demand)**-ийн шууд аналог гэж үзэж болно.

| Metric          |   Value |
| --------------- | ------: |
| Failed requests |   **0** |
| Total requests  | **230** |
| Error rate      |  **0%** |

Error Rate = Failed Requests / Total Requests × 100% = 0 / 230 × 100% = 0%

Нийт 230 request-ээс нэг ч request амжилтгүй болоогүй. Иймээс error rate буюу POFOD-той адилтган үзсэн үзүүлэлт нь 0% байна.

<!-- LOAD_TEST_RESULTS_START -->

## Staged Load Test Results

| VU  | Duration | p90 (ms) | p95 (ms) | Throughput (req/s) | Error Rate |
| --- | -------- | -------- | -------- | ------------------ | ---------- |
| 5   | 1m       | 228.7    | 230.3    | 7.57               | 0.00%      |
| 30  | 1m       | 236.9    | 242.0    | 45.20              | 0.00%      |
| 100 | 1m       | 234.0    | 237.5    | 150.02             | 0.00%      |

<!-- LOAD_TEST_RESULTS_END -->

30 VU орчимд нэг хэрэглэгчийн latency муудах шинж анх ажиглагдсан. Харин 100 VU хүртэл систем throughput-оо нэмэгдүүлсээр, error rate 0% хэвээр байгаа тул одоогоор ноцтой performance degradation харагдахгүй байна.

## SLO (Service Level Objective)

SLO-г baseline хэмжилтийн `http_req_duration` **p95** үзүүлэлтэд үндэслэн сонгосон.

Baseline хэмжилтийн p95:

```text
p95 = 229.56 ms

SLO = baseline p95 × 1.3
= 229.56 ms × 1.3
= 298.43 ms
```

30%-ийн хүлцэл нэмсэн шалтгаан нь ачаалал болон зэрэгцээ хэрэглэгчдийн тоо нэмэгдэх үед latency тодорхой хэмжээгээр өсөх боломжийг харгалзан үзэх явдал юм. Baseline-ийн p95-ийг шууд SLO болговол бага хэмжээний ачааллын өөрчлөлтөд ч SLO зөрчигдөх эрсдэлтэй. Тиймээс тестийн үед:

```text
p95(http_req_duration) ≤ 298.43 ms
```

байвал latency-ийн SLO хангагдсан гэж үзнэ.
