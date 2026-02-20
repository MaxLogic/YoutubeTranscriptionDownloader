# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Added
- Channel mode (`-c/--channel`) to download transcripts for all videos from the seed video's channel.
- Channel options: `-j/--jobs`, `-ov/--override`, `-co/--channel-output`, `-is/--include-shorts`, `-il/--include-live`.
- Authentication options for yt-dlp channel/video requests: `--cookies` and `--cookies-from-browser`.
- Channel pacing option: `-dj/--delay-jitter-ms` for per-item random delay.

### Changed
- Channel-mode output defaults to `<output-root>/<channel-name>/` and uses title-based names with `video_id`-aware skip/overwrite logic.
- Channel downloads run in bounded parallel workers with retry/backoff and throttling cooldown handling.
- Channel mode now always writes metadata front matter including `channel` and `video_id`.
- Channel default worker count is now conservative: `min(logical CPU, 2)`.
- Repeated anti-bot/throttle signals now trigger adaptive worker-limit reduction and longer cooldown delays.
