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

## Local сервер лүү хийсэн тест

| VU  | Duration | p90 (ms) | p95 (ms) | Throughput (req/s) | Error Rate |
| --- | -------- | -------- | -------- | ------------------ | ---------- |
| 100 | 60s      | 305.84   | 306.95   | 75.82              | 0%         |
| 100 | 60s      | 4.79     | 6.73     | 99.63              | 0%         |

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

Load test-ийн үр дүнгээс харахад сервер 100 VU-ийн ачааллын үед хүсэлтүүдийг амжилттай боловсруулж, error rate 0% байсан.  
Delay-гүй үед p90 response time 4.79 ms, p95 response time 6.73 ms, throughput 99.63 req/s байсан.  
Харин request бүрт 300 ms-ийн delay нэмэхэд p90 305.84 ms, p95 306.95 ms болж response time мэдэгдэхүйц өссөн.  
Үүний зэрэгцээ throughput 99.63 req/s-ээс 75.82 req/s хүртэл буурсан.  
Энэ нь нэг request-ийг боловсруулах хугацаа нэмэгдэхэд серверийн нэгж хугацаанд боловсруулах боломжтой request-ийн тоо буурдаг болохыг харуулж байна.  
Мөн 100 VU-ийн ачаалалтай байсан ч хоёр туршилтад бүх request амжилттай боловсруулагдсан бөгөөд системийн тогтвортой байдал хадгалагдсан.  
Ингэснээр лекцийн **latency, throughput, concurrency** гэсэн ойлголтууд практик туршилтаар батлагдсан.  
Ялангуяа latency өсөхөд throughput буурдаг гэсэн хамаарал туршилтын үр дүнгээр тодорхой харагдсан.  
Мөн load testing нь системийн response time болон throughput-д ачаалал, processing delay хэрхэн нөлөөлж байгааг хэмжих боломжийг олгодог нь батлагдсан.
