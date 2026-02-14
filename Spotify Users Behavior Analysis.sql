/*
Project   : Spotify Streaming History - SQL Exploration
Objective : Objective 1 - User Listening Behavior
Author    : Muhammad Rifqi Fauzi
Notes     :
- 1 row = 1 playback event
- ts represents the time when the track finished playing
*/


/* Objective I:
Pola konsumsi musik pengguna */

# 1. Total Aktivitas Mendengarkan per Platform
# Platform apa yang paling sering digunakan untuk mendengarkan musik?

SELECT
    platform,
    COUNT(*) AS total_plays
FROM streaming_history
GROUP BY platform
ORDER BY total_plays DESC;

# 2. Total Durasi Mendengarkan per Platform
# Platform mana yang menghasilkan waktu mendengarkan terlama?

SELECT
    platform,
    ROUND(SUM(ms_played) / 60000.0, 2) AS total_minutes_played
FROM streaming_history
GROUP BY platform
ORDER BY total_minutes_played DESC;

# 3. Jam Paling Aktif Mendengarkan Musik
# Pada jam berapa user paling aktif mendengarkan musik?


SELECT
    EXTRACT(HOUR FROM ts) AS listening_hour,
    COUNT(*) AS total_plays
FROM streaming_history
GROUP BY listening_hour
ORDER BY total_plays DESC;



# 4. Aktivitas Mendengarkan per Hari
# Hari apa yang paling sering digunakan untuk mendengarkan musik?
SELECT
    TO_CHAR(ts, 'Day') AS day_name,
    COUNT(*) AS total_plays
FROM streaming_history
GROUP BY day_name
ORDER BY total_plays DESC;

# 5. Rata-rata Durasi Pemutaran Lagu
# Berapa rata-rata durasi lagu yang didengarkan user?
SELECT
    ROUND(AVG(ms_played) / 1000.0, 2) AS avg_seconds_played
FROM streaming_history;

# 6. Weekday vs Weekend
SELECT
    CASE
        WHEN EXTRACT(DOW FROM ts) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_plays,
    ROUND(AVG(ms_played) / 1000.0, 2) AS avg_seconds_played
FROM streaming_history
GROUP BY day_type;

/*
========================================
OBJECTIVE 2
User Preference: Track, Artist, Album
========================================
*/


# 7. Lagu Paling Sering Diputar
# Lagu apa yang paling sering diputar oleh user?

SELECT
    track_name,
    artist_name,
    COUNT(*) AS play_count
FROM streaming_history
GROUP BY track_name, artist_name
ORDER BY play_count DESC
LIMIT 10;

# 8. Lagu dengan Total Durasi Mendengarkan Terlama
# Lagu mana yang menghasilkan total waktu mendengarkan tertinggi?

SELECT
    track_name,
    artist_name,
    ROUND(SUM(ms_played) / 60000.0, 2) AS total_minutes_played
FROM streaming_history
GROUP BY track_name, artist_name
ORDER BY total_minutes_played DESC
LIMIT 10;

# 9. Artis Paling Banyak Didengarkan
# Artis mana yang paling banyak didengarkan user?

SELECT
    artist_name,
    COUNT(*) AS play_count,
    ROUND(SUM(ms_played) / 60000.0, 2) AS total_minutes_played
FROM streaming_history
GROUP BY artist_name
ORDER BY total_minutes_played DESC
LIMIT 10;

# 10. Album dengan Engagement Tertinggi
# Album mana yang paling tinggi engagement-nya?

SELECT
    album_name,
    artist_name,
    COUNT(*) AS play_count,
    ROUND(SUM(ms_played) / 60000.0, 2) AS total_minutes_played
FROM streaming_history
GROUP BY album_name, artist_name
ORDER BY total_minutes_played DESC
LIMIT 10;

# 11. Skip Rate per Lagu
# Lagu mana yang sering di-skip?

SELECT
    track_name,
    artist_name,
    COUNT(*) AS total_plays,
    SUM(CASE WHEN skipped THEN 1 ELSE 0 END) AS skip_count,
    ROUND(
        SUM(CASE WHEN skipped THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS skip_rate_percentage
FROM streaming_history
GROUP BY track_name, artist_name
HAVING COUNT(*) >= 5
ORDER BY skip_rate_percentage DESC;

/*
========================================
OBJECTIVE 3
Skip Behavior & User Engagement Analysis
========================================

Tujuan:
Memahami faktor-faktor yang memengaruhi skip behavior dan tingkat engagement pengguna.
*/

# 12. Skip Rate Keseluruhan
# Berapa persentase lagu yang di-skip oleh user?

SELECT
    COUNT(*) AS total_plays,
    SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) AS total_skips,
    ROUND(
        SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS skip_rate_percentage
FROM streaming_history;

# 13. Pengaruh Shuffle terhadap Skip Rate
# Apakah mode shuffle meningkatkan kemungkinan lagu di-skip?

SELECT
    shuffle,
    COUNT(*) AS total_plays,
    SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) AS total_skips,
    ROUND(
        SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS skip_rate_percentage
FROM streaming_history
GROUP BY shuffle;

# 14. Platform Mana yang Paling Tinggi Skip Rate-nya
# Apakah platform tertentu memiliki skip rate lebih tinggi?

SELECT
    platform,
    COUNT(*) AS total_plays,
    SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) AS total_skips,
    ROUND(
        SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS skip_rate_percentage
FROM streaming_history
GROUP BY platform
ORDER BY skip_rate_percentage DESC;

# 15. Apakah Lagu dengan Durasi Pendek Lebih Sering di-Skip?
# Apakah lagu dengan durasi play pendek cenderung di-skip?

SELECT
    CASE
        WHEN ms_played < 30000 THEN 'Less than 30 sec'
        WHEN ms_played < 120000 THEN '30 sec - 2 min'
        ELSE 'More than 2 min'
    END AS listening_duration_category,
    
    COUNT(*) AS total_plays,
    
    SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) AS total_skips,
    
    ROUND(
        SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS skip_rate_percentage

FROM streaming_history

GROUP BY listening_duration_category

ORDER BY skip_rate_percentage DESC;
 
# 16. Jam dengan Skip Rate Tertinggi
# Apakah skip behavior dipengaruhi oleh waktu?

SELECT
    EXTRACT(HOUR FROM ts) AS hour_of_day,
    COUNT(*) AS total_streams,

    SUM(CASE 
        WHEN skipped = TRUE THEN 1 
        ELSE 0 
    END) AS total_skipped,

    ROUND(
        SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS skip_rate_percentage

FROM streaming_history

GROUP BY hour_of_day

ORDER BY skip_rate_percentage DESC;