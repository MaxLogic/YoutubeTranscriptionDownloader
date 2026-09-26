# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Added
- Channel mode (`-c/--channel`) to download transcripts for all videos from the seed video's channel.
- Channel options: `-j/--jobs`, `-ov/--override`, `-co/--channel-output`, `-is/--include-shorts`, `-il/--include-live`.
- Authentication options for yt-dlp channel/video requests: `--cookies` and `--cookies-from-browser`.
- `cookies_from_browser=auto` (settings.ini, YAML `defaults`, and `--cookies-from-browser auto`) tries Firefox, Chrome, then Edge once per run with a local cookie probe that makes no YouTube request, and uses the first browser that works. Runs without an effective cookie source print a logged-out notice at start and on the first HTTP 429 or bot challenge, with the fix (`cookies_from_browser=firefox`) and the Windows Chrome/Edge limitation.
- Channel pacing option: `-dj/--delay-jitter-ms` for random delay between yt-dlp invocations.
- YAML queue mode (`-f/--file`) with grouped subfolders, mutable run state, retained failures, and `fresh`/`failed`/`all` eligibility.
- madExcept crash reporting with automatic HTTPS submission to the server-side mail queue and non-interactive Debug capture through `MAXLOGIC_MADEXCEPT_AI`.

### Changed
- Transcript fetches now split extraction from the subtitle download. The extraction run (`operation: transcript`) no longer requests subtitles. yttrans picks the track from `info.json` and downloads that one signed timedtext URL through `yt-dlp --load-info-json` (`operation: subtitle`), keeping yt-dlp's cookie and impersonation handling. A timedtext HTTP 429 retry reuses the saved URL until shortly before it expires instead of re-extracting the page. Captionless videos are detected from `info.json` without a timedtext request. The `en` fallback no longer costs a second extraction.
- Pacing now follows the request class. The 10-to-20-second randomized gap and its throttle-level recovery spacing apply between subtitle downloads only. Extraction, metadata, listing, and RSS requests wait a short base gap (`--base-interval-ms`, default 3000, or the YAML `base_interval_ms` field in `defaults`, groups, or entries; `0` is honored). The base gap is capped at the subtitle interval, so an explicit `request_interval_ms: 0` stays unpaced. Cooldowns still block every request. A saved subtitle URL that would expire during a pending cooldown or pacing wait is re-extracted before the wait, not after it. `--sleep-subtitles` is no longer passed to yt-dlp; the `--sleep-subtitles` option and the YAML `sleep_subtitles_seconds` field are accepted but ignored.
- Track choice now prefers manual subtitles, then automatic captions that are not machine-translated (`<lang>`/`<lang>-orig` without `tlang`), and machine-translated captions last. Subtitle run-log entries record `track_kind` (`manual`, `auto`, `auto_translated`).
- Channel-mode output defaults to `<output-root>/<channel-name>/` and uses title-based names with `video_id`-aware skip/overwrite logic.
- Channel downloads run in bounded parallel workers with retry/backoff and throttling cooldown handling.
- Channel mode now always writes metadata front matter including `channel` and `video_id`.
- Channel default worker count is now `1`.
- Repeated anti-bot/throttle signals now trigger adaptive worker-limit reduction and longer cooldown delays.
- YouTube calls now default to a random 10-to-20-second interval, and throttling uses nine adaptive levels with recovery after each five successful video downloads.
- Adaptive pacing now uses bounded throttle-level recovery intervals instead of an unbounded multiplier. With default jitter, levels 1–8 use 15–25 through 75–85 seconds, preventing a fast burst after a long cooldown while recovery state persists across restarts.
- Internal yt-dlp pacing now defaults to 1 second between extraction requests and 5 seconds before subtitle downloads without a throttle-level multiplier. Transcript-only requests skip HLS/DASH manifests and use an installed Node runtime for YouTube JavaScript challenges.
- yt-dlp invocations now write sanitized JSONL timing and response classifications, distinguishing rate limits, bot challenges, and configuration failures.
- File-mode channel candidates are sorted newest-first and channels rotate after each outbound video attempt, giving every eligible source one deterministic turn before the next channel round.
- Channel metadata, merged listings, local transcript IDs, child-failure state, and the next candidate cursor are cached across turns for the lifetime of a YAML process.
- YAML channel discovery now persists `.yttrans-channel-index.json`, uses RSS for routine fresh scans, reconciles fully at least every 30 days or in `all` mode, and preserves indexed history on failed, malformed, or throttled discovery.
- Cooldown output now reports the level, remaining duration, UTC retry time, and channel progress without repeated unchanged progress lines.
- Throttle level 9 now parks for another jittered 90-minute cooldown and resumes automatically at level 8. Interrupted parked entries remain resumable in `throttled` mode.
- YAML summaries distinguish deferred queue entries from deferred channel videos and checkpoint final channel counters.
- YAML jobs share one throttle controller across channel and standalone-video requests.
- YAML throttles now checkpoint and rotate the retained entry after one probe instead of retrying one target inline forever. Channel children already probed in the current cycle are skipped until every outstanding child has had a turn; the shared cooldown still gates every request.
- A target receives at most two rate-limit attempts per YAML run. Only its first HTTP 429 raises the global throttle level; a second 429 retains that target as failed without another global escalation, and the run ends with exit code 1 after all other runnable work completes.
- Persisted throttle levels now decay by one for each complete 90-minute idle period after the saved cooldown expires, preventing an old high level from imposing recovery pacing on a much later restart.
- Age-confirmation warnings are no longer misclassified as bot challenges; only actual not-a-bot confirmation text enters the level-9 park.
- Channel probe cycles now requeue until previously throttled child videos are revisited, so terminal summaries cannot hide deferred children. Captionless and cached-unavailable children no longer inflate channel or top-level failure counts.
- The channel unavailable cache now stores all failed child videos in schema 2 and migrates schema-1 entries when saved.
- YAML jobs that complete with retained failures now return exit code 1.
- Fatal runtime faults now pass through the outer command-line handler to madExcept after the YAML checkpoint is written.
- Transcript front matter is now valid YAML. Values stay plain where YAML allows it; titles and other text that contain `: `, ` #`, a leading indicator such as `-` or `"`, or read as a bool or number are double-quoted with escapes, and `description` is an indented `|-` block. Existing unquoted files are still read for `video_id` dedup and are not rewritten (T-032).
- `-j/--jobs` and YAML `jobs` are deprecated: still validated so old commands and files work, but ignored. Channel mode uses one worker because the shared gate already spaces subtitle downloads 10 to 20 seconds apart. The worker-limit and effective-worker code is removed, along with the `Workers configured`/`Workers final limit` console lines (T-033).

### Fixed
- yt-dlp now starts when yttrans is installed in a folder whose path contains spaces, and a failed start no longer leaks pipe handles (T-028).
- yt-dlp stdout and stderr are read until the pipes close, so the tail of large output and a final stderr line are no longer lost. yt-dlp gets `NUL` as stdin (T-029).
- Persistent channel-index stores now retain a function-scoped owner during discovery and reconciliation, preventing a use-after-free access violation.
- Fatal runtime-corruption exceptions checkpoint the YAML queue and stop the process instead of being recorded as ordinary entry failures.
- yt-dlp responses are classified only from stderr `ERROR:`/`WARNING:` lines. Metadata or listing JSON whose titles mention rate limits or bots is no longer treated as throttling, and the benign PO-token warning on a saved transcript no longer blocks probe completion or recovery credit (T-022).
- YAML channel entries whose metadata, listing, or RSS discovery keeps returning HTTP 429 now stop after two attempts per run and are recorded as throttled; only HTTP 429 responses consume this budget, and successful responses clear a target's rate-limit attempts (T-027).
- An RSS HTTP 429 without status text is now classified as a rate limit and enters the shared cooldown instead of ending as one ordinary failure (T-034).
- Fatal exceptions inside channel workers are unwrapped from `EAggregateException`, so YAML mode checkpoints and stops instead of retaining the channel as an ordinary failure. A non-fatal worker failure is recorded with its inner message (T-030).
- Transcript files are written to a temp file in the same folder and moved into place, so a killed run can no longer leave a partial file whose `video_id` front matter makes later runs skip the video. The temp name `.yttrans-<8 hex>.tmp` is short, so paths near the 260-character limit still work. Leftover temp files are ignored by the `video_id` scan and deleted by a later write to that folder once they are more than an hour old (T-031).
