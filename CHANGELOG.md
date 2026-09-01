# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Added
- Channel mode (`-c/--channel`) to download transcripts for all videos from the seed video's channel.
- Channel options: `-j/--jobs`, `-ov/--override`, `-co/--channel-output`, `-is/--include-shorts`, `-il/--include-live`.
- Authentication options for yt-dlp channel/video requests: `--cookies` and `--cookies-from-browser`.
- Channel pacing option: `-dj/--delay-jitter-ms` for random delay between yt-dlp invocations.
- YAML queue mode (`-f/--file`) with grouped subfolders, mutable run state, retained failures, and `fresh`/`failed`/`all` eligibility.

### Changed
- Channel-mode output defaults to `<output-root>/<channel-name>/` and uses title-based names with `video_id`-aware skip/overwrite logic.
- Channel downloads run in bounded parallel workers with retry/backoff and throttling cooldown handling.
- Channel mode now always writes metadata front matter including `channel` and `video_id`.
- Channel default worker count is now `1`.
- Repeated anti-bot/throttle signals now trigger adaptive worker-limit reduction and longer cooldown delays.
- YouTube calls now default to a random 10-to-20-second interval, and throttling uses nine adaptive levels with recovery after each five successful video downloads.
- Adaptive pacing now increases by 50 percent per throttle level and persists the level, recovery-success count, and cooldown deadline across queue restarts.
- Internal yt-dlp pacing now defaults to 3 seconds between extraction requests and 5 seconds before subtitle downloads, with both base values scaled by the active throttle level and rounded up.
- File-mode channel candidates are sorted newest-first and large channels rotate after 50 uncached-video attempts so later queue entries run in the same process.
- Channel metadata and merged listings are cached across slices for the lifetime of a YAML process.
- YAML channel discovery now persists `.yttrans-channel-index.json`, uses RSS for routine fresh scans, reconciles fully at least every 30 days or in `all` mode, and preserves indexed history on failed, malformed, or throttled discovery.
- Cooldown output now reports the level, remaining duration, UTC retry time, and channel progress without repeated unchanged progress lines.
- Throttle level 9 now parks for another jittered 90-minute cooldown and resumes automatically at level 8. Interrupted parked entries remain resumable in `throttled` mode.
- YAML summaries distinguish deferred queue entries from deferred channel videos and checkpoint final channel counters.
- YAML jobs share one throttle controller across channel and standalone-video requests.
- The channel unavailable cache now stores all failed child videos in schema 2 and migrates schema-1 entries when saved.
