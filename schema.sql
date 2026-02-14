Spotify Streaming History Database Schema
Author: Muhammad Rifqi Fauzi

-- Buat table utama
CREATE TABLE streaming_history (
    id SERIAL PRIMARY KEY,

    spotify_track_uri TEXT,
    ts TIMESTAMP,
    platform VARCHAR(50),

    ms_played INTEGER,

    track_name TEXT,
    artist_name TEXT,
    album_name TEXT,

    reason_start VARCHAR(50),
    reason_end VARCHAR(50),

    shuffle BOOLEAN,
    skipped BOOLEAN
);
