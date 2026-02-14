# Spotify Streaming History – SQL Exploration

## Project Overview
Project ini bertujuan untuk melakukan eksplorasi data menggunakan SQL pada dataset histori pemutaran lagu Spotify.  
Analisis difokuskan pada pola konsumsi musik, preferensi lagu, serta faktor yang memengaruhi engagement dan skip behavior pengguna.

---

## Dataset Description
Dataset berisi histori pemutaran lagu Spotify dengan informasi waktu, platform, lagu, artis, serta perilaku pengguna saat mendengarkan musik.

---

## 1. Entity Relationship Diagram (ERD) – Logical View

Dataset ini hanya terdiri dari satu tabel, sehingga ERD yang digunakan adalah **logical ERD** untuk membantu memahami struktur data dan granularitas analisis, bukan desain database fisik.

### Entitas Utama: `streaming_history`

Setiap baris data merepresentasikan **satu event pemutaran lagu**.

**Kolom utama:**
- `spotify_track_uri`
- `ts`
- `platform`
- `ms_played`
- `track_name`
- `artist_name`
- `album_name`
- `reason_start`
- `reason_end`
- `shuffle`
- `skipped`

### Cara Data Analyst Membaca Data:
- 1 baris = 1 event pemutaran lagu
- Bukan 1 lagu unik
- Lagu yang sama dapat muncul berkali-kali dalam dataset

---

### Logical Breakdown (Konseptual)

Untuk memudahkan analisis, data dipisahkan secara **konseptual** menjadi dua entitas:

#### Track
- `spotify_track_uri` (Primary Key)
- `track_name`
- `artist_name`
- `album_name`

#### Playback_Event
- `event_id` (implicit)
- `spotify_track_uri` (Foreign Key)
- `ts`
- `platform`
- `ms_played`
- `reason_start`
- `reason_end`
- `shuffle`
- `skipped`

**Relasi:**
- Satu Track dapat memiliki banyak Playback Event  
  (Track 1 --- * Playback_Event)

### Kenapa ERD Ini Penting?
- Jumlah lagu ≠ jumlah pemutaran
- Popularitas lagu ≠ hanya frekuensi kemunculan
- Mencegah kesalahan agregasi saat analisis SQL

---

## 2. Analysis Assumptions

Asumsi berikut digunakan untuk menjaga konsistensi dan validitas hasil analisis.

### Asumsi Data & Struktur
1. Setiap baris data merepresentasikan satu kali pemutaran lagu.
2. `spotify_track_uri` digunakan sebagai unique identifier lagu.
3. Kolom `ts` menunjukkan waktu lagu selesai diputar, bukan waktu mulai.
4. Dataset tidak menyediakan durasi asli (full length) lagu.

### Asumsi Perilaku Pengguna
5. Lagu dianggap di-skip jika `skipped = TRUE`.
6. Lagu dianggap didengarkan sampai selesai jika `skipped = FALSE`, meskipun nilai `ms_played` tidak selalu sama dengan durasi asli lagu.
7. Lagu dengan `ms_played < 30.000` ms diasumsikan sebagai **quick skip** (kurang dari 30 detik).

### Asumsi Engagement
8. Total `ms_played` digunakan sebagai proxy tingkat engagement pengguna.
9. Lagu dengan frekuensi play tinggi dan tingkat skip rendah dianggap memiliki **high user preference**.
10. Mode shuffle diasumsikan dapat memengaruhi tingkat skip dan engagement lagu.

---

## 3. Analysis Objectives
Berdasarkan ERD dan asumsi di atas, analisis SQL difokuskan pada:
1. Pola konsumsi musik pengguna
2. Preferensi lagu, artis, dan album
3. Faktor yang memengaruhi skip dan engagement

(Query SQL dan insight hasil analisis tersedia pada file terpisah.)
