# yttrans

[![Made with Delphi](https://img.shields.io/badge/Made%20with-Delphi-blue?style=flat-square&logo=delphi)](https://www.embarcadero.com/products/delphi)

A simple, fast command-line tool for downloading YouTube video transcripts.

yttrans acts as a lightweight wrapper around the powerful `yt-dlp` engine, focusing on one task: fetching the plain text of a video's subtitles without downloading the video itself.

## Features

*   **Transcript Focused:** Downloads only the subtitle track, not the entire video.
*   **Language Selection:** Specify the desired transcript language (e.g., `en`, `pl`, `de`).
*   **Flexible Output:** Print the transcript directly to the console or save it to a text file.
*   **Channel Mode:** Start from one video URL and download transcripts for the whole channel.
*   **YAML Download Queue:** Process grouped channels and videos as one throttled job while retaining failures for later runs.
*   **Authenticated Access:** Optional cookie-based authentication for YouTube requests.
*   **Retry and Pacing:** Channel mode retries transient failures with backoff behind one shared request-pacing gate.
*   **Clean Text:** Automatically parses the SRT subtitle format into clean, readable plain text.
*   **Lightweight:** A single, native executable with no runtime dependencies other than `yt-dlp`.

## Requirements

yttrans requires **`yt-dlp.exe`** to function.

*   You must download `yt-dlp.exe` from the official [yt-dlp GitHub Releases page](https://github.com/yt-dlp/yt-dlp/releases/latest).
*   Place `yt-dlp.exe` in the **same directory** as `yttrans.exe`.
*   `settings.ini` can be placed in the same directory as `yttrans.exe` to control auto-update and default app options.

### Auto-Update Settings

At startup, yttrans checks `settings.ini` (next to `yttrans.exe`) and can run `yt-dlp -U` automatically when due.

Default file:

```ini
[auto-update]
enabled=1
last-check=
interval-in-days=7

[default]
meta=true
output_dir=output\
prefix_separator= - 
cookies_file=
cookies_from_browser=
# cookies_from_browser=firefox
# cookies_from_browser=auto
# cookies_from_browser=firefox:default-release
# cookies_from_browser=chrome:Profile 1

[meta]
url=true
title=true
channel=true
created=true
keywords=true
video_id=true
uploader=true
uploader_id=true
channel_id=true
duration=true
view_count=true
like_count=true
comment_count=true
tags=true
description=false
```

Rules:
*   `enabled=1` enables checks (`0` disables).
*   `last-check` stores the last check date (`yyyy-mm-dd`).
*   If `last-check` is empty or older than `interval-in-days`, yttrans tries an update and then refreshes `last-check`.
*   `default.meta` enables metadata by default. True values include: `true`, `t`, `yes`, `y`, `on`, `enabled`, `1`.
*   `default.output_dir` can be relative (to `yttrans.exe`) or absolute. When used, transcript file name is auto-generated from the YouTube title with `.md` extension.
*   `default.prefix_separator` controls how `-p/--prefix` is glued to auto-generated title file names.
*   `default.cookies_file` sets a yt-dlp cookies file used when no cookie CLI args are passed.
*   `default.cookies_from_browser` sets a browser cookie source used when no cookie CLI args are passed.
    *   Profile selectors are supported via yt-dlp syntax, e.g. `firefox:default-release`, `chrome:Profile 1`.
    *   `auto` tries Firefox, then Chrome, then Edge, and uses the first browser that holds a signed-in YouTube session. See [Logged-in and Premium users](#logged-in-and-premium-users).
*   Set only one of `default.cookies_file` or `default.cookies_from_browser`.
*   Without an effective cookie source, yttrans prints a short logged-out notice at the start of a run and once more on the first HTTP 429 or bot challenge.

### Logged-in and Premium users

YouTube rate-limits logged-out requests per IP address, so subtitle downloads without cookies hit HTTP 429 sooner. If you are signed in to YouTube in a browser, the recommended setup is:

```ini
[default]
cookies_from_browser=firefox
```

or `cookies_from_browser=auto` (the CLI equivalent is `--cookies-from-browser firefox` or `--cookies-from-browser auto`).

*   yt-dlp reads the cookies fresh from the browser profile on every run, so there is nothing to export or refresh by hand.
*   Firefox works on Windows. Chrome and Edge usually fail there: current versions use app-bound cookie encryption that yt-dlp cannot decrypt ("Failed to decrypt with DPAPI"), and a running Chrome/Edge locks its cookie database.
*   `auto` resolves once per run. yttrans runs one local yt-dlp probe per browser that loads the cookies into a temporary file without contacting YouTube, deletes that file immediately, and prints which browser it chose, or a warning if none worked. In that case the run continues logged out.
*   Cookie values are never printed or written to `yttrans.run.jsonl`.
*   `[meta]` allows enabling/disabling each metadata line independently.
*   Auto-generated output files never overwrite existing files (`name.md`, `name (2).md`, ...).
*   In channel mode, files are grouped under `<output-root>/<channel-name>/` and matching `video_id` files are skipped by default.

### Crash Reports

Fatal runtime faults, including access violations and invalid-pointer errors, are handled by madExcept. YAML mode checkpoints the current queue entry before the fault reaches the top-level handler. The application then saves `bugreport.log` next to `yttrans.exe` and uploads the report over HTTPS to the MaxLogic bug-report queue. The server sends the email separately. Expected download failures, missing captions, and YouTube throttling remain normal queue errors and do not create crash reports.

Debug builds support unattended crash capture for agent runs. Set `MAXLOGIC_MADEXCEPT_AI=1` before starting the executable. In this mode madExcept suppresses its UI, does not upload a report, removes any stale `bugreport.txt`, writes one fresh report next to the executable, and exits with code `207`. Release builds ignore this environment variable.

Command-line Delphi builds must run `madExceptPatch` after compilation so madExcept can embed settings and stack information. The repository's DelphiAIKit build command performs that step when it finds the matching `yttrans.mes` file.

## Installation

1.  Download the latest `yttrans.exe` from the [Releases](https://github.com/your-username/your-repo/releases) page of this repository.
2.  Download `yt-dlp.exe` from its [official repository](https://github.com/yt-dlp/yt-dlp/releases/latest).
3.  Place both `yttrans.exe` and `yt-dlp.exe` in the same folder.
4.  (Optional) For easy access from anywhere, add this folder to your system's `PATH` environment variable.

## Usage

The basic command structure is:

```bash
yttrans <URL> [options]
```

### Examples

**1. Get a transcript in English and print it to the console:**

```bash
yttrans "https://www.youtube.com/watch?v=dQw4w9WgXcQ" -l en
```

**2. Get a transcript in Polish and save it to a file:**

```bash
yttrans "https://www.youtube.com/watch?v=some_video_id" -l pl -o "C:\Transcripts\MyTranscript.txt"
```

**3. Get the default English transcript and save it to a file in the current directory:**
*(The `-l` flag defaults to `en` if omitted)*

```bash
yttrans "https://www.youtube.com/watch?v=another_video_id" -o transcript.txt
```

**4. Save to a directory and auto-name the file from video title:**

```bash
yttrans "https://www.youtube.com/watch?v=another_video_id" -o "C:\Transcripts\"
```

**5. Add a filename prefix for auto-generated names:**

```bash
yttrans "https://www.youtube.com/watch?v=another_video_id" -o "C:\Transcripts\" -p "AI Related"
```

**6. Include metadata keywords (auto-enables meta):**

```bash
yttrans "https://www.youtube.com/watch?v=another_video_id" -keywords "delphi, subtitles, tutorial"
```

**7. Display the help message:**

```bash
yttrans -h
```

**8. Download all channel videos from a seed URL:**

```bash
yttrans "https://www.youtube.com/watch?v=VIDEO_ID" -c
```

**9. Channel mode with custom root dir and Shorts/Live tabs:**

```bash
yttrans "https://www.youtube.com/watch?v=VIDEO_ID" -c -o "C:\Transcripts\" -is -il
```

**10. Channel mode with browser cookies (recommended for anti-bot challenges):**

```bash
yttrans "https://www.youtube.com/watch?v=VIDEO_ID" -c --cookies-from-browser firefox
```

**11. Retry videos previously recorded without a transcript:**

```bash
yttrans "https://www.youtube.com/watch?v=VIDEO_ID" -c --retry-unavailable
```

### YAML Download File Mode

File mode replaces a list of separate batch commands with one coordinated queue:

```bash
yttrans --file download.yaml
```

Copy [`download.sample.yaml`](download.sample.yaml) to the ignored local `download.yaml`, then edit its groups. A group can set one `subfolder` for every channel and standalone video below it:

```yaml
schema: 1
mode: fresh

defaults:
  language: en
  output_dir: output
  request_interval_ms: 10000
  delay_jitter_ms: 10000
  base_interval_ms: 3000
  sleep_requests_seconds: 1
  socket_timeout_seconds: 60

groups:
  - name: MaxLogic examples
    subfolder: MaxLogic
    channels:
      - url: https://www.youtube.com/@MaxLogicPawel
    videos:
      - url: https://www.youtube.com/watch?v=lRQae-tRw-k
```

Relative `output_dir` values resolve from the YAML file directory. Standalone videos in the example write below `output/MaxLogic/`; channel videos write below `output/MaxLogic/<channel-name>/`.

The top-level modes are:

*   `fresh`: process new standalone entries and healthy channels. A channel with a valid index newer than 30 days uses YouTube RSS; a missing, invalid, or stale index triggers a complete listing.
*   `failed`: retry retained failed entries and cached channel failures. Valid channel indexes are reused without RSS; a complete listing runs only when no valid index exists.
*   `throttled`: retry only entries and channel children whose last failure was throttling. Valid channel indexes are reused without RSS; known captionless videos remain skipped.
*   `all`: process all enabled entries, force complete channel reconciliation, and retry cached channel failures.

Successfully downloaded standalone video entries are removed from the YAML file. Channel entries remain so later runs can discover new uploads. Failures retain their error category, message, attempt timestamp, and available YouTube metadata. Ordinary entry failures do not stop later entries, but a queue that finishes with recorded failures returns exit code `1`. Runtime-corruption errors such as access violations checkpoint the current entry and stop immediately. One shared throttle controller applies across the complete file. Its level, recovery-success count, guarded-request count, cooldown deadline, and most recent throttle classification are saved in the top-level `state` and restored after a restart. Run modes select eligible work; they do not bypass an active YouTube cooldown. In YAML mode, a throttled request is checkpointed and its entry moves to the back of the queue after one probe. The next request, even for a different entry, still waits for the shared cooldown. Direct URL and channel commands continue waiting and retrying inline.

The queue is locked while running and checkpointed through a backup plus atomic replacement after each attempted entry. Channel candidates are ordered by publication date, newest first. File mode makes at most one outbound video attempt from a channel before rotating that unfinished channel behind the other eligible sources. The source ring follows YAML order, while every channel retains newest-first child order. Its in-memory cache retains the listing, local transcript IDs, child-failure state, and next candidate cursor, so rotation does not reopen every transcript or rescan the channel from its first video. A channel with a child deferred by throttling gives every other outstanding child a turn before one final retry. After a second HTTP 429 in the same run, that child remains recorded as throttled, no longer blocks the queue, and causes the orderly run to finish with errors. Captionless children remain reported as unavailable and do not by themselves make the channel or top-level job fail. The first successful complete discovery writes `.yttrans-channel-index.json` in the resolved channel directory. Routine `fresh` runs merge RSS entries into that history; successful complete reconciliations also union their result with the saved history, so omitted, private, or temporarily hidden videos are not deleted from the index. Invalid, failed, or throttled discovery leaves the last valid primary or `.bak` unchanged. Long channels and RSS cooldowns checkpoint during periodic progress updates. The yt-dlp extraction-request sleep defaults to 1 second and stays fixed while cooldown levels change. `sleep_subtitles_seconds` is still accepted for compatibility but ignored: yttrans spaces subtitle downloads itself. Transcript-only video operations skip HLS and DASH manifest extraction, and the installed Node runtime is enabled automatically for YouTube JavaScript challenges. Explicit pacing values, including zero, remain effective. If another editor changes the YAML file during a run, yttrans refuses to overwrite that edit. The complete schema is specified in [`docs/specs/2026-08-30-yaml-download-file-mode-spec.md`](docs/specs/2026-08-30-yaml-download-file-mode-spec.md).

### Command-Line Arguments & Options

Use `yttrans` for these options. `-meta` is not a `yt-dlp` flag.

| Argument / Option | Alias        | Description                                                                                             |
| ----------------- | ------------ | ------------------------------------------------------------------------------------------------------- |
| `<URL>`           |              | The YouTube video or channel seed URL used by direct mode.                                              |
| `-f`, `--file`    |              | Process a mutable YAML queue. Cannot be combined with a URL or direct-mode options.                     |
| `-l`, `--lang`    |              | The language code for the subtitles (e.g., `en`, `pl`). Defaults to `en` if not specified.                |
| `-o`, `--output`  |              | Video mode: output file path or directory. Channel mode: root output directory for `<channel-name>/` files. |
| `-p`, `--prefix`  |              | Prefix for auto-generated file names. Separator comes from `settings.ini` key `default.prefix_separator`. |
| `-meta`, `--meta` |              | Prepends metadata before transcript text. Individual fields are controlled by `[meta]` switches in `settings.ini`. |
| `-keywords`       |              | Comma-separated keywords added to metadata section. Automatically enables `-meta`.                      |
| `-c`, `--channel` |              | Channel mode. Uses the seed video URL to discover the owning channel and download channel transcripts. |
| `-j`, `--jobs`    |              | Deprecated; the value is validated and ignored. Channel mode uses one worker because the shared gate already spaces subtitle downloads. |
| `-ov`, `--override` |            | Channel mode only. Overwrite file if existing front matter has the same `video_id`.                    |
| `-co`, `--channel-output` |      | Channel mode only. Override root output directory (same semantics as `-o` in channel mode).           |
| `-is`, `--include-shorts` |      | Channel mode only. Include videos from Shorts tab (best effort; warns if tab is missing).             |
| `-il`, `--include-live` |        | Channel mode only. Include videos from Live/Streams tab (best effort; warns if tab is missing).       |
| `--cookies`       |              | Use yt-dlp cookies file for authenticated requests. Overrides `settings.ini` defaults.                  |
| `--cookies-from-browser` |       | Load cookies from a browser/profile (yt-dlp syntax, e.g. `firefox:default-release`, `chrome:Profile 1`), or `auto` to try Firefox, Chrome, then Edge. Overrides `settings.ini` default. |
| `--request-interval-ms` |       | Minimum delay between yt-dlp invocations (default `10000`).                                      |
| `-dj`, `--delay-jitter-ms` |     | Maximum random delay added between yt-dlp invocations (default `10000`).                         |
| `--sleep-requests` |           | Delay between yt-dlp extraction requests in seconds (default `1`; not scaled by throttle level). |
| `--base-interval-ms` |         | Short minimum delay before any YouTube request, including extraction, metadata, and RSS (default `3000`). Capped at the subtitle interval. Also applies with `-f` unless the YAML sets `base_interval_ms`. |
| `--sleep-subtitles` |          | Deprecated and ignored: yttrans paces subtitle downloads itself (`--request-interval-ms`, `--delay-jitter-ms`). |
| `--socket-timeout` |           | yt-dlp network socket timeout in seconds (default `60`; `0` uses the yt-dlp default).             |
| `-ru`, `--retry-unavailable` |   | Channel mode only. Retry videos recorded in `.yttrans-unavailable.json`.                              |
| `-h`, `--help`    |              | Displays the help message and exits.                                                                    |

### Channel Mode Behavior

*   Default scope is regular uploads/videos only.
*   `-is` and `-il` expand scope to Shorts and Live tabs.
*   Channel mode always writes metadata front matter and enforces `channel` + `video_id` fields for dedup/overwrite logic.
*   File naming in channel mode is title-based (`<title>.md`), with conflict probing (`<title> (2).md`, ...) when title collisions refer to different `video_id`s.
*   Existing file with same `video_id` is skipped by default; use `-ov` to overwrite.
*   Front matter is valid YAML. Values stay plain when YAML allows it (`video_id: abcDEF12345`, URLs, dates, counts). A value that would otherwise break or change type is double-quoted with backslash escapes, for example a title containing `: ` or ` #`, starting with `"`, `#`, `[` or `- ` (a dash followed by a space), or reading as `true`, `123` or `12:34`. `description` is a `|-` literal block indented two spaces. Files written before this change keep unquoted values and are still read for `video_id` dedup.
*   Transcript files are written to a short `.yttrans-<8 hex>.tmp` file in the same folder and then moved into place, so an interrupted run never leaves a partial `.md` file. A leftover temp file is ignored by the `video_id` scan and deleted by a later write to that folder once it is more than an hour old.
*   Failed channel children are saved in `<channel>/.yttrans-unavailable.json` with status, error category, URL, title, last-attempt UTC timestamp, and published timestamp when available. Existing schema-1 unavailable caches are migrated when saved.
*   Cached failures are skipped without contacting YouTube. Use `--retry-unavailable` in direct mode, YAML mode `throttled` for transient throttle failures, or `failed`/`all` for every cached failure. Successful retries remove their manifest entries.
*   Track order for `-l de`: original English, original German, English translation, German translation, then the video's own language. English always comes before the requested language. All are chosen from one extraction.
*   Processing is best-effort: failed videos are reported as warnings and do not stop the whole channel run.
*   Channel candidates are sorted by publication date, newest first. Entries without a usable date retain their discovery order after dated entries.
*   The channel name, queue size, and output directory are printed before item processing. Progress is printed every 100 changed items, at completion, or after 60 seconds of changed progress. During cooldown, a concise level, remaining-time, retry-time, and channel-progress line is printed every five minutes.
*   YAML standalone videos run before channels, including their bounded retry, preserving YAML order within each kind. Channels then rotate after one outbound video attempt.
*   YAML transcript 429s are evaluated by source. When another source has saved a transcript and only one source fails, its 429 does not raise the shared level or reset recovery progress. Failures from multiple sources without an intervening saved transcript trigger shared backoff. With no successful peer evidence (including a single-source job), backoff remains conservative. Discovery failures and bot challenges retain shared protection.
*   After three distinct throttled videos from a channel while another source succeeds, that channel pauses for 10 minutes; other sources continue. One post-pause transcript probe is allowed. Another 429 exhausts the channel for this run, retaining its remaining videos and finishing with errors. An ordinary non-throttle result ends the probe; only a saved transcript earns recovery credit. `state.source_pause_active`, `source_pause_until_utc`, and `source_retry_exhausted` record this decision. Active pause deadlines survive restart; exhaustion is bounded to one run, with normal mode eligibility governing the next run.
*   Global levels 1 through 8 still wait 2, 5, 10, 15, 30, 45, 60, and 90 minutes respectively, with plus or minus 10 percent jitter. Level 9 parks the process for another jittered 90-minute cooldown, then resumes automatically at level 0. If only paused channels remain, the process waits for their deadlines and reports progress every 30 seconds.
*   A YAML target receives at most two rate-limit attempts in one run. A channel entry whose metadata, listing, or RSS discovery is rate-limited gets the same two-attempt budget. Its second HTTP 429 does not raise the global level or start another long cooldown. The target remains recorded as throttled, processing continues, and an orderly run with exhausted targets finishes as `completed_with_errors` with exit code `1`. Direct URL and direct channel modes retain inline retry behavior.
*   A bot-confirmation challenge is classified separately and enters the level-9 unattended park immediately. After the park expires, the next request starts from level 0, including after a restart with an expired deadline. Age-confirmation messages are not bot challenges. PO-token and JavaScript-runtime messages are configuration failures and do not consume the rate-limit escalation schedule. Responses are classified only from yt-dlp's `ERROR:` and `WARNING:` lines on stderr, never from the metadata JSON on stdout. Configuration failures count only as `ERROR:` lines, so the PO-token warning on a run that saved its subtitles still counts as a success.
*   Pacing depends on the request class. Subtitle (timedtext) downloads are spaced 10 to 20 seconds apart. Every request, including extraction, metadata, listing, and RSS, only waits a short base gap after the previous call (`--base-interval-ms` or YAML `base_interval_ms`, default 3 seconds). The base gap never exceeds the subtitle interval, so `request_interval_ms: 0` with zero jitter disables pacing entirely. A captionless video therefore costs an extraction and a few seconds, not a full slot. Active global cooldowns and source pauses still block every class. While recovering, throttle levels 1 through 8 raise the default bounded spacing to 15–25, 20–30, 25–35, 30–40, 40–50, 50–60, 60–70, and 75–85 seconds respectively. This avoids a fast burst immediately after a long cooldown. Cooldown levels never multiply yt-dlp internal sleeps.
*   In YAML mode, each five newly saved or overwritten transcripts lower the throttle level by one. No-caption responses, cache skips, metadata, and discovery do not earn credit. Isolated source failures preserve partial recovery progress. Direct mode retains its existing successful-video-request rule. Recovery state survives short restarts. With an expired cooldown, every complete 90-minute interval since the last throttle response lowers the restored level once; idle decay starts a fresh recovery window.
*   A transcript fetch has two yt-dlp steps. `operation: transcript` is extraction only (`--skip-download --write-info-json`, no subtitle request and no subtitle sleep). yttrans then picks the track from `info.json` (`srt` only), English before the requested language: original tracks (manual subtitles, then automatic captions that are not machine-translated: `<lang>` or `<lang>-orig` with no `tlang` in the URL) in English, then in the requested language; then machine-translated automatic captions (URL with `tlang`) in English, then in the requested language; and last, an original track in the video's own language (`info.json` `language`, or the `<lang>-orig` automatic captions). A video without such a track is recorded as unavailable with no subtitle request. Otherwise `operation: subtitle` runs `yt-dlp --load-info-json` on a copy of `info.json` reduced to that one track and stripped of `webpage_url`/`original_url`. yt-dlp therefore makes exactly one timedtext request with its usual cookies, headers, and impersonation, and cannot fall back to a second extraction. When that request gets HTTP 429, the retry (inline, or when the YAML entry comes back from the queue in the same process) reuses the saved signed URL while its `expire` time is more than 10 minutes away. A fresh extraction runs only after that point, or once after HTTP 403/410.
*   `yttrans.run.jsonl` records yt-dlp invocations with source, target, gate wait, `pacing_wait_ms`, `global_cooldown_wait_ms`, execution duration, exit code, and throttle state. `operation` separates extraction (`transcript`) from the timedtext download (`subtitle`); entries logged before this change used `transcript` for the combined call. Each `subtitle` entry also records `track_kind` (`manual`, `auto`, or `auto_translated`). To compare the 429 rate per kind, run `Get-Content yttrans.run.jsonl | ConvertFrom-Json | Where-Object operation -eq 'subtitle' | Group-Object track_kind, response_kind -NoElement | Sort-Object Name` in PowerShell next to `yttrans.exe`. Separate `operation: transcript_saved` events identify files actually written; do not count every exit-zero invocation as a downloaded transcript. Source pauses and exhaustion are identified in console output and entry state. Command arguments and cookie values are not logged.
*   YAML file mode shares pacing and cooldown state across every channel and standalone video in the queue. It rotates a channel after one outbound video attempt, preventing a large channel from monopolizing the queue. A throttled channel child is probed only once per in-memory rotation cycle and at most twice per run. The process remains alive for confirmed global cooldowns, but it does not wait indefinitely for one exhausted target. If the process is killed during a level-9 park, `throttled` mode resumes the checkpointed entry and waits out the saved global cooldown; after the deadline, the throttle level resets to 0.

### Anti-Bot Guidance

*   Prefer authenticated requests for channel mode:
    *   `--cookies-from-browser <browser>` when running on your own machine profile (`firefox` or `auto` on Windows).
    *   `--cookies <file>` when using an exported cookies file.
*   Requests run one at a time. `-j`/`--jobs` and YAML `jobs` are accepted for old commands and files but ignored.
*   Keep pacing enabled:
    *   subtitle downloads are randomly spaced 10 to 20 seconds apart by default, and any other yt-dlp call waits the 3-second base gap;
    *   recovery spacing rises with the active throttle level, from 15–25 seconds at level 1 to 75–85 seconds at level 8;
    *   yt-dlp uses a 1-second extraction-request sleep without a throttle-level multiplier; `--sleep-subtitles` is no longer passed;
    *   `request_interval_ms` sets the subtitle interval and `delay_jitter_ms` adds a random value from zero through the configured maximum;
    *   `base_interval_ms` (YAML `defaults`, groups, or entries) overrides the `--base-interval-ms` base gap; `0` is honored;
    *   tune both pacing options above if needed.
*   If YouTube challenges requests, rerun with cookies first.
*   YouTube does not publish a fixed wait that clears website rate limiting. The [yt-dlp 429 guidance](https://github.com/yt-dlp/yt-dlp/wiki/FAQ#http-error-429-too-many-requests-or-402-payment-required) describes it as an IP soft block that may require solving a CAPTCHA and passing matching browser cookies.

