# Lyrics timing in Nova Music

Nova uses timing data supplied by its lyric source. It never estimates word positions from a line timestamp.

## LRCLIB

Nova requests LRCLIB with the track title and artist, plus album and duration when Now Playing has them. The response's `lyricsfile` can contain `lines[].words[]` with individual `start_ms` values. When those values are present, Now Playing highlights each word as playback crosses its timestamp and labels the track **Word-by-word**.

If the record has no usable timed words, Nova falls back to LRCLIB's `syncedLyrics` LRC field. Standard LRC timestamps mark whole lines, so Nova highlights the active line and labels it **Line sync only**. Plain untimed lyrics are not presented as synchronized lyrics.

The current provider path supports LRCLIB Lyricsfile word timings and its line-timed LRC fallback. Local `.lrc`/enhanced `.lrc` sidecar import and other lyric providers are not implemented yet.

## Data rules

- Every word highlight comes from a source `start_ms` value (or a genuine inline enhanced-LRC word timestamp).
- A line with no word timestamps remains line-synchronized even if its text contains several words.
- Existing lyric caches are versioned so older line-only entries are fetched again and can be upgraded when word timings are available.
