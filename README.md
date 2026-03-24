# social_network_system_design

## I've joined [system design course](https://balun.courses/courses/system_design) and try to deepen my understanding in system design

### Functional requirements:
- Publishing travel posts with photos, a short description, and a link to a specific travel destination
- Rating and commenting on other travelers' posts
- Subscribing to other travelers to follow their activity
- Searching for popular travel destinations and viewing posts from those places
- Viewing other travelers' feeds and a user feed based on subscriptions in reverse chronological order
- Support phone & web

### Non-functional requirements
- 10 000 000 DAU
- Support x2 load on holidays (new year, winter, summer), duration is 3 months
- Write 1 post per week
    - Pictures: max 512 KB per picture (do compression), max 10 pictures, 4 pictures on avg
    - Description: max 2048 chars, max 4096 bytes (not 1 byte per char due to CIS country focus), 512 chars on avg
    - Location: 200 bytes
- Write 5 reactions for posts per day
- Write 2 comments for posts per day (text <= 1024 chars)
- Read feed x5 including search (10 posts per request) per day
    - Max 2 seconds per request
    - 1 MB size of each compressed picture
- Write 3 subscribe/cancel to someone per day
    - ~100 subscriptions per user
    - ~500 subscribers per user
    - Consider celebrities, max 1 million subs
- For CIS countries
- 99.9% availability per year (~8 hours of downtime)

### RPS
- TPS (Transactions Per Second):
    - Post: 10 000 000 / 7 / 86 400 = 16, peak 32
    - Reactions: 10 000 000 * 5 / 86 400 = 575, peak 1150
    - Comments: 10 000 000 * 2 / 86 400 = 230, peak 460
    - Subscribe/cancel: 10 000 000 * 3 / 86 400 = 345, peak 690
- QPS (Queries Per Second):
    - Feed: 10 000 000 * 5 / 86 400 = 575, peak 1150

### Traffic
- TPS (Transactions Per Second):
    - Post:
        - media: 16 rps * (512 KB picture * 4 number of pictures on avg) = 16 * 2 MB = 32 MB/s, peak 64 MB/s
        - metadata: 16 rps * (1024 bytes desc. + 200 bytes location) = 16 * 2 KB = 32 KB/s, peak 64 KB/s
    - Reactions: 575 rps * 100 bytes = 56 KB/s, peak 112 KB/s
    - Comments: 230 rps * 300 bytes = 70 KB/s, 140 KB/s
    - Subscribe/cancel: 345 rps * 100 bytes = 34 KB/s, peak 68 KB/s
- QPS (Queries Per Second):
    - Feed:
        - media: 575 rps * (512 KB picture * 4 number of pictures on avg) * 10 posts = 575 * 2 MB * 10 posts = 11 500 MB/s ≈ 12 GB/s, peak 24 GB/s
        - metadata: 575 rps * (1024 + 200) bytes * 10 posts = 575 * 12 KB = 6 900 KB/s≈ 6.9 MB/s, peak 13.8 MB/s

### Storage
- Posts (incl. seasonality) (metadatas and blobs are stored in the same disk):
    Сapacity = 50 MB/s * 86 400 * 365 = 1 600 000 000 MB = 1.6 PB
    Disks_for_capacity = 1.6 PB / 100 TB = 16
    Disks_for_throughput = 18 GB/s / 500 MB/s = 32
    Disks_for_iops = 1000 / 1000 = 1
    Disks = max(ceil(16), ceil(32), ceil(1)) = x32 SSD (SATA) disks
- Reactions (incl. seasonality):
    Сapacity = 80 KB/s * 86 400 * 365 = 2 500 000 000 KB = 2.5 TB
    Disks_for_capacity = 2.5 TB / 2 TB = 1.3
    Disks_for_throughput = 80 KB/s / 100 MB/s ≈ 0
    Disks_for_iops = 800 / 100 = 8
    Disks = max(ceil(1.3), ceil(0), ceil(8)) = x8 SSD (SATA) disks
- Comments (incl. seasonality):
    Сapacity = 100 KB/s * 86 400 * 365 = 3 100 000 000 KB = 3.1 TB
    Disks_for_capacity = 3.1 TB / 2 TB = 1.7
    Disks_for_throughput = 100 KB/s / 100 MB/s ≈ 0
    Disks_for_iops = 300 / 100 = 3
    Disks = max(ceil(1.7), ceil(0), ceil(3)) = x3 SSD (SATA) disks

- Conclusion: x32 SSD (SATA) more preffered for our system