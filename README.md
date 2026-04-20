# social_network_system_design

## I've joined [system design course](https://balun.courses/courses/system_design) and try to deepen my understanding in system design

### Functional requirements:
- Publishing travel posts with photos, a short description, and a link to a specific travel destination
- Rating and commenting on other travelers posts
- Subscribing/Unsubscribing to other travelers to follow their activity
- Searching for popular travel destinations and viewing posts from those places
- Viewing other travelers' feeds based on subscriptions and a user feed, both in reverse chronological order
- Support phone & web

### Non-functional requirements
- 10 000 000 DAU
- Support x2 load on holidays (new year, winter holidays, summer holidays), overall duration is 3 months
- 99.9% availability per year (~8 hours of downtime)
- For CIS countries
- Write 1 post per week
    - 3 seconds for creation
    - Pictures: max 512 KB per picture (do compression on a client side), max 10 pictures, 4 pictures on avg
    - Description: max 2048 chars, max 4096 bytes (not 1 byte per char due to CIS country focus), 512 chars on avg
    - Location data: 512 bytes
- Write 5 reactions for posts per day
- Write 2 comments for posts per day (text <= 1024 chars)
- Read feed x5 (10 posts per request) per day
    - Eventual consistency on reading other travelers posts
    - Get feed for 2 seconds
- Read feed by searching place x2 (10 posts per request) per day
    - Eventual consistency on reading other travelers posts
    - Get feed for 3 seconds
- Write 1 subscribe/unsubscribe to someone per day
    - subscribe/unsubscribe in 1 second
    - ~100 subscriptions per user
    - ~100 subscribers per user
    - Consider celebrities, max 1 million subs

### RPS
- TPS (Transactions Per Second):
    - Post: 10 000 000 / 7 / 86 400 = 16, peak 32
    - Reactions: 10 000 000 * 5 / 86 400 = 575, peak 1150
    - Comments: 10 000 000 * 2 / 86 400 = 230, peak 460
    - Subscribe/unsubscribe: 10 000 000 * 1 / 86 400 = 115, peak 230
- QPS (Queries Per Second):
    - Feed: 10 000 000 * 5 / 86 400 = 575, peak 1150
    - Searching places: 10 000 000 * 2 / 86 400 = 230, peak 460

### Traffic
- TPS (Transactions Per Second):
    - Post:
        - media: 16 rps * (512 KB picture * 4 number of pictures on avg) = 16 * 2 MB = 32 MB/s, peak 64 MB/s
        - metadata: 16 rps * (1024 bytes desc. + 512 bytes location) = 16 * 2 KB = 32 KB/s, peak 64 KB/s
    - Reactions: 575 rps * 100 bytes = 56 KB/s, peak 112 KB/s
    - Comments: 230 rps * 300 bytes = 70 KB/s, 140 KB/s
    - Subscribe/unsubscribe: 115 rps * 100 bytes = 12 KB/s, peak 24 KB/s
- QPS (Queries Per Second):
    - Feed:
        - media: 575 rps * (512 KB picture * 4 number of pictures on avg) * 10 posts = 575 * 2 MB * 10 posts = 11 500 MB/s = 12 GB/s, peak 24 GB/s
        - metadata: 575 rps * (1024 + 512) bytes * 10 posts = 575 * 20 KB = 12 000 KB/s = 12 MB/s, peak 24 MB/s
    - Searching places:
        - media: 230 rps * (512 KB picture * 4 number of pictures on avg) * 10 posts = 230 * 2 MB * 10 posts = 4 600 MB/s = 5 GB/s, peak 10 GB/s
        - metadata: 230 rps * (1024 + 512) bytes * 10 posts = 230 * 20 KB = 4 600 KB/s = 5 MB/s, peak 10 MB/s

### Storage

Disks_for_capacity = capacity / disk_capacity
Disks_for_throughput = traffic_per_second / disk_throughput
Disks_for_iops = iops / disk_iops
Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops))

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

### Replication & Sharding
- database: PgSQL + S3
- async, replication factor - 2, master-slave
- hash based sharding, `post_id` as key, consistent hashing approach
    - Why `post_id`, not `user_id`?
    - in case `post_id` viral posts retrieves faster since data in one shard
    - since user feed take a place, it can lead to cross shard queries, handle with Redis

- Posts
    - Hosts = 32 disks / 2 disks_per_host = 16
    - Hosts_with_replication = 16 hosts * 2 replication_factor = 32
- Reactions
    - Hosts = 8 disks / 2 disks_per_host = 4
    - Hosts_with_replication = 4 hosts * 2 replication_factor = 8
- Comments
    - Hosts = 3 disks / 2 disks_per_host = 2
    - Hosts_with_replication = 2 hosts * 2 replication_factor = 4