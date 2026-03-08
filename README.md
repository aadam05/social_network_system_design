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
- 10 000 000 DAU with peak traffic 2x
- Write 1 post per week
    - Pictures: max 3 MB per picture, max 10 pictures, 3 pictures on avg
    - Description: max 2048 chars, max 4096 bytes (not 1 byte per char due to CIS country focus), 512 chars on avg
    - Location: 200 bytes
- Write 5 reactions for posts per day
- Write 2 comments for posts per day (text <= 1024 chars)
- Read feed x5 including search (10 posts per request) per day
    - Max 2 seconds per request
    - 1 MB size of each compressed picture
- ~100 subscriptions per user
- ~500 subscribers per user
- Write 3 subscribe/cancel to someone per day
- Consider celebrities, max 1 million subs
- For CIS countries
- Store data infinitely
- 99.9% availability per year (~8 hours of downtime)

### RPS
- TPS (Transactions Per Second):
    - Post: 10 000 000 / 7 / 86 400 = 16, peak 32
- QPS (Queries Per Second):
    - Feed: 10 000 000 * 5 / 86 400 = 575, peak 1150
    - Reactions: 10 000 000 * 5 / 86 400 = 575, peak 1150
    - Comments: 10 000 000 * 2 / 86 400 = 230, peak 230
    - Subscribe/cancel: 10 000 000 * 3 / 86 400 = 345, 

### Traffic
- TPS (Transactions Per Second):
    - Post:
        - media: 16 rps * (3072 KB picture * 3 number of pictures on avg) = 16 * 9 MB = 144 MB/s, peak 288 MB/s
        - metadata: 16 rps * (1024 bytes desc. + 200 bytes location) = 16 * 2 KB = 32 KB/s, peak 64 KB/s
- QPS (Queries Per Second):
    - Feed:
        - media: 575 rps * ((1024 KB picture * 3 number of pictures on avg) * 10 posts per request) = 575 * 3 MB * 10 = 17 250 MB/s = 17 GB/s, peak 32 GB/s
        - metadata: 575 rps * (1024 bytes desc. + 200 bytes location * 10 posts per request) = 575 * 12 KB * 10 = 69 000 KB/s = 69 MB/s, peak 138 MB/s
    - Reactions: 575 rps * 100 bytes = 56 KB/s, peak 112 KB/s
    - Comments: 230 rps * 300 bytes = 70 KB/s, 140 KB/s
    - Subscribe/cancel: 345 rps * 100 bytes = 34 KB/s, peak 68 KB/s

### Storage
- Posts: 128 MB/s * 86 400 * 365 = 4 036 608 000 MB = 4 PB/year
- Comments: 70 KB/s * 86 400 * 365 = 2 207 520 000 KB = 2 TB/year