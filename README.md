# B232270029, З.Анхбаяр

## Суурь хэмжилт

### Туршилтын тохиргоо

- **Target:** `https://test.k6.io`
- **Virtual Users (VUs):** 5
- **Duration:** 30 секунд
- **Total iterations:** 115
- **Total HTTP requests:** 230
- **K6 version:** k6 v2.2.0 (commit/00a9a1b7f5, go1.26.5, linux/amd64)

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

Туршилтыг 3 өөр ачааллын түвшинд хийсэн бөгөөд тус бүрийг 1 минут ажиллуулсан.

- **Stages:** 3
- **5 VU:** 1 минут
- **30 VU:** 1 минут
- **100 VU:** 1 минут

| VU  | Duration | p90 (ms) | p95 (ms) | Throughput (req/s) | Error Rate |
| --- | -------- | -------- | -------- | ------------------ | ---------- |
| 5   | 1m       | 226.0    | 228.0    | 7.60               | 0.00%      |
| 30  | 1m       | 236.9    | 242.0    | 45.20              | 0.00%      |
| 100 | 1m       | 234.0    | 237.5    | 150.02             | 0.00%      |

<!-- LOAD_TEST_RESULTS_END -->

30 VU орчимд нэг хэрэглэгчийн latency муудах шинж анх ажиглагдсан. Харин 100 VU хүртэл систем throughput-оо нэмэгдүүлсээр, error rate 0% хэвээр байгаа тул одоогоор ноцтой performance degradation харагдахгүй байна.

## SLO (Service Level Objective)

SLO-г baseline хэмжилтийн `http_req_duration` **p95** үзүүлэлтэд үндэслэн сонгосон.

Baseline хэмжилтийн p95:

```text
p95 = 229.56 ms

SLO = baseline p95 × 1.5
= 229.56 ms × 1.5
= 344
```

50%-ийн хүлцэл нэмсэн шалтгаан нь ачаалал болон зэрэгцээ хэрэглэгчдийн тоо нэмэгдэх үед latency тодорхой хэмжээгээр өсөх боломжийг харгалзан үзэх явдал юм. Baseline-ийн p95-ийг шууд SLO болговол бага хэмжээний ачааллын өөрчлөлтөд ч SLO зөрчигдөх эрсдэлтэй. Тиймээс тестийн үед:

```text
p95(http_req_duration) ≤ 344 ms
```

байвал latency-ийн SLO хангагдсан гэж үзнэ.

## THRESHOLDS

30 VU / 1 минутын ачааллын үед системийн гүйцэтгэлийг `http_req_duration` metric-ийн `p(95)` үзүүлэлтээр шалгасан.

### FAIL

```text
Threshold: http_req_duration p(95) < 65 ms
Actual:    p(95) = 234.08 ms
Result:    FAIL
```

95%-ийн хүсэлт 65 ms-ээс бага хугацаанд хариу өгөх ёстой гэсэн threshold тавьсан боловч бодит `p(95)` нь **234.08 ms** байсан. Иймээс уг threshold биелээгүй.

### PASS

```text
Threshold: http_req_duration p(95) < 344 ms
Actual:    p(95) = 232.65 ms
Result:    PASS
```

95%-ийн хүсэлт 344 ms-ээс бага хугацаанд хариу өгөх ёстой гэсэн threshold тавихад бодит `p(95)` нь **232.65 ms** байсан. Иймээс уг threshold биелсэн.

### Харьцуулалт

| Үзүүлэлт                  |      FAIL |       PASS |
| ------------------------- | --------: | ---------: |
| VU                        |        30 |         30 |
| Хугацаа                   |   1 минут |    1 минут |
| HTTP requests             |      2762 |       2776 |
| `http_req_duration` p(95) | 234.08 ms |  232.65 ms |
| Threshold                 | `< 65 ms` | `< 344 ms` |
| Threshold result          |      FAIL |       PASS |
| HTTP request failure rate |        0% |         0% |
| Checks                    | 1381/1381 |  1388/1388 |

Үр дүнгээс харахад ижил 30 VU / 1 минутын ачааллын үед бодит `p(95)` response time ойролцоогоор **233–234 ms** байна. Тиймээс 65 ms гэсэн хатуу threshold биелээгүй боловч 344 ms гэсэн threshold биелсэн. Мөн хоёр туршилтын үед HTTP status 200 check бүх хүсэлт дээр амжилттай болсон.

## Local сервер лүү хийсэн тест

| VU  | Duration | p90 (ms) | p95 (ms) | Throughput (req/s) | Error Rate |
| --- | -------- | -------- | -------- | ------------------ | ---------- |
| 100 | 60s      | 305.84   | 306.95   | 75.82              | 0%         |
| 100 | 60s      | 4.79     | 6.73     | 99.63              | 0%         |

Load testing-д ашигласан local test server:

[GitHub Repository](https://github.com/Anhkbayar/test-server)

Load test-ийн үр дүнгээс харахад серверт 300 мс-ийн artificial delay нэмэхэд гүйцэтгэл мэдэгдэхүйц буурсан байна. Delay-гүй үед p90 нь 4.79 мс, p95 нь 6.73 мс, throughput нь 99.63 req/s байсан бол 300 мс delay-тэй үед p90 305.84 мс, p95 306.95 мс, throughput 75.82 req/s болж буурсан.

Мөн хоёр туршилтын үед хоёуланд нь error rate 0% байсан бөгөөд бүх request амжилттай хариу өгсөн. Иймээс delay нь серверийн найдвартай байдалд нөлөөлөөгүй ч response time болон нийт throughput-д шууд сөргөөр нөлөөлсөн гэж дүгнэсэн.

## Ажиллуулах комманд

Үр дүнг харахын тулд заавар дээр txt хэлбэрээр гэсэн байсан ч надад json форматаар харах нь илүү ойлгомжтой байсан ба мөн staged туршилтыг хийгээд хэмжилтийг хийгээд автоматаар README.md файл рүү бичихэд хэрэгтэй байсан тул гаралтыг харахын тулд

```bash
k6 run --summary-export=results/[Гаралтын файлын нэр].json [скриптын нэр].ts
```

Харин .sh -ийг ажиллуулахын тулд

```bash
chmod +x ./run_load_test.sh
VUS=[Хийсвэр хэрэглэгчийн тоо] ./run_load_test.sh [TARGET_URL] [DURATION]
```

## Дүгнэлт

`test.k6.io` сервер дээр 5, 30, 100 VU гэсэн 3 үе шаттайгаар, үе шат бүрийг 1 минут ажиллуулж load test хийсэн. Ачааллыг 5 VU-ээс 100 VU хүртэл нэмэгдүүлэхэд throughput нь **7.60 req/s-ээс 45.20 req/s, цаашлаад 150.02 req/s** болж өссөн. Энэ нь зэрэгцээ хэрэглэгчдийн тоо нэмэгдэхэд сервер нэгж хугацаанд илүү олон request боловсруулах боломжтой байсныг харуулж байна.

Latency-ийн хувьд 5 VU үед p95 нь **228.0 ms**, 30 VU үед **242.0 ms**, 100 VU үед **237.5 ms** байсан. Өөрөөр хэлбэл VU-ийн тоо 5-аас 100 хүртэл өссөн боловч p95 latency огцом өсөөгүй бөгөөд ойролцоогоор 230–240 ms-ийн түвшинд хадгалагдсан. Мөн гурван түвшний туршилтад error rate **0%** байсан тул бүх request амжилттай боловсруулагдсан.

Ингэснээр `test.k6.io` дээр хийсэн туршилтаар concurrency нэмэгдэхэд throughput өсөж, latency харьцангуй тогтвортой байж болохыг ажигласан. Харин local серверийн туршилтаар request бүрт **300 ms artificial delay** нэмэхэд p95 latency **306.95 ms** болж өсөж, throughput **75.82 req/s** хүртэл буурсан. Delay-гүй үед p95 нь **6.73 ms**, throughput нь **99.63 req/s** байсан тул processing delay нь latency болон throughput-д шууд нөлөөлж байгааг харуулсан.

Эдгээр туршилтууд нь лекцийн **latency, throughput, concurrency** гэсэн үндсэн ойлголтуудыг практик байдлаар харуулсан. Ялангуяа request боловсруулах хугацаа нэмэгдэхэд нэгж хугацаанд боловсруулах request-ийн тоо буурч болох нь local серверийн туршилтаар тодорхой харагдсан. Харин `test.k6.io` дээр 5-аас 100 VU хүртэл ачаалал нэмэгдсэн ч error rate 0% хэвээр байсан бөгөөд throughput ачаалалтай хамт өссөн.
