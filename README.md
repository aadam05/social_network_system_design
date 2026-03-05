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
- Write 1 post per week
    - Pictures: max 3 MB per picture, max 10 pictures, 3 pictures on avg
    - Description: max 2048 chars, max 4096 bytes (not 1 byte per char due to CIS country focus), 512 chars on avg
    - Location: 200 bytes
- Write 5 reactions for posts per day
- Write 2 comments for posts per day (text <= 1024 chars)
- Read feed x5 including search (10 posts per request) per day
    - Max 2 seconds per request
- ~100 subscriptions per user
- ~500 subscribers per user
- Write 3 subscribe/cancel to someone per day
- Consider celebrities, max 1 million subs
- For CIS countries
- Store data infinitely
- 99.9% availability per year (~8 hours of downtime)

### RPS
- Read feed: 10 000 000 * 5 / 86 400 = 575
- Write post: 10 000 000 / 7 / 86 400 = 16
- Write reactions: 10 000 000 * 5 / 86 400 = 575
- Write comments: 10 000 000 * 2 / 86 400 = 230
- Write subscribe/cancel: 10 000 000 * 3 / 86 400 = 345

### Traffic
- Read feed: 575 rps * (1024 bytes desc. + 200 bytes location + 8092 KB pictures) * 10 posts per request = 575 * 9 MB * 10 = 52 000 MB/s = 52 GB/s
- Write post: 16 rps * (1024 bytes desc. + 200 bytes location + 8092 KB pictures) = 16 * 8 MB/s = 128 MB/s
- Write reactions: 575 rps * 100 bytes = 56 KB/s
- Write comments: 230 rps * 300 bytes = 70 KB/s
- Write subs: 345 rps * 100 bytes = 34 KB/s

### Storage
- Posts: 128 MB/s * 86 400 * 365 = 4 036 608 000 MB = 4 PB/year
- Comments: 70 KB/s * 86 400 * 365 = 2 207 520 000 KB = 2 TB/year
