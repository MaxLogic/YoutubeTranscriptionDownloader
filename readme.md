# yttrans

[![Made with Delphi](https://img.shields.io/badge/Made%20with-Delphi-blue?style=flat-square&logo=delphi)](https://www.embarcadero.com/products/delphi)

A simple, fast command-line tool for downloading YouTube video transcripts.

yttrans acts as a lightweight wrapper around the powerful `yt-dlp` engine, focusing on one task: fetching the plain text of a video's subtitles without downloading the video itself.

## Features

*   **Transcript Focused:** Downloads only the subtitle track, not the entire video.
*   **Language Selection:** Specify the desired transcript language (e.g., `en`, `pl`, `de`).
*   **Flexible Output:** Print the transcript directly to the console or save it to a text file.
*   **Channel Mode:** Start from one video URL and download transcripts for the whole channel.
*   **Authenticated Access:** Optional cookie-based authentication for YouTube requests.
*   **Parallel Processing:** Channel mode supports worker parallelism (`-j`) with retry/backoff on transient failures.
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
cookies_from_browser=firefox
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
*   Set only one of `default.cookies_file` or `default.cookies_from_browser`.
*   `[meta]` allows enabling/disabling each metadata line independently.
*   Auto-generated output files never overwrite existing files (`name.md`, `name (2).md`, ...).
*   In channel mode, files are grouped under `<output-root>/<channel-name>/` and matching `video_id` files are skipped by default.

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

**9. Channel mode with custom root dir, worker count, and Shorts/Live tabs:**

```bash
yttrans "https://www.youtube.com/watch?v=VIDEO_ID" -c -o "C:\Transcripts\" -j 8 -is -il
```

**10. Channel mode with browser cookies (recommended for anti-bot challenges):**

```bash
yttrans "https://www.youtube.com/watch?v=VIDEO_ID" -c --cookies-from-browser chrome
```

### Command-Line Arguments & Options

Use `yttrans` for these options. `-meta` is not a `yt-dlp` flag.

| Argument / Option | Alias        | Description                                                                                             |
| ----------------- | ------------ | ------------------------------------------------------------------------------------------------------- |
| `<URL>`           |              | The full URL of the YouTube video. This is a **required** argument.                                     |
| `-l`, `--lang`    |              | The language code for the subtitles (e.g., `en`, `pl`). Defaults to `en` if not specified.                |
| `-o`, `--output`  |              | Video mode: output file path or directory. Channel mode: root output directory for `<channel-name>/` files. |
| `-p`, `--prefix`  |              | Prefix for auto-generated file names. Separator comes from `settings.ini` key `default.prefix_separator`. |
| `-meta`, `--meta` |              | Prepends metadata before transcript text. Individual fields are controlled by `[meta]` switches in `settings.ini`. |
| `-keywords`       |              | Comma-separated keywords added to metadata section. Automatically enables `-meta`.                      |
| `-c`, `--channel` |              | Channel mode. Uses the seed video URL to discover the owning channel and download channel transcripts. |
| `-j`, `--jobs`    |              | Max parallel workers in channel mode. Defaults to `min(logical CPU count, 2)`.                         |
| `-ov`, `--override` |            | Channel mode only. Overwrite file if existing front matter has the same `video_id`.                    |
| `-co`, `--channel-output` |      | Channel mode only. Override root output directory (same semantics as `-o` in channel mode).           |
| `-is`, `--include-shorts` |      | Channel mode only. Include videos from Shorts tab (best effort; warns if tab is missing).             |
| `-il`, `--include-live` |        | Channel mode only. Include videos from Live/Streams tab (best effort; warns if tab is missing).       |
| `--cookies`       |              | Use yt-dlp cookies file for authenticated requests. Overrides `settings.ini` defaults.                  |
| `--cookies-from-browser` |       | Load cookies from a browser/profile (yt-dlp syntax, e.g. `firefox:default-release`, `chrome:Profile 1`). Overrides `settings.ini` default. |
| `-dj`, `--delay-jitter-ms` |     | Max random per-item delay in milliseconds in channel mode (default `1200`).                            |
| `-h`, `--help`    |              | Displays the help message and exits.                                                                    |

### Channel Mode Behavior

*   Default scope is regular uploads/videos only.
*   `-is` and `-il` expand scope to Shorts and Live tabs.
*   Channel mode always writes metadata front matter and enforces `channel` + `video_id` fields for dedup/overwrite logic.
*   File naming in channel mode is title-based (`<title>.md`), with conflict probing (`<title> (2).md`, ...) when title collisions refer to different `video_id`s.
*   Existing file with same `video_id` is skipped by default; use `-ov` to overwrite.
*   Requested subtitle language is tried first, then fallback to default language (`en`) when that language is unavailable.
*   Processing is best-effort: failed videos are reported as warnings and do not stop the whole channel run.
*   On repeated throttling/anti-bot signals, the tool increases cooldown delays and can reduce active worker concurrency automatically.

### Anti-Bot Guidance

*   Prefer authenticated requests for channel mode:
    *   `--cookies-from-browser <browser>` when running on your own machine profile.
    *   `--cookies <file>` when using an exported cookies file.
*   Keep concurrency conservative unless needed:
    *   default is `min(logical CPU, 2)`;
    *   raise with `-j` only when the channel is stable and not rate-limited.
*   Keep pacing enabled:
    *   default per-item jitter is `1200ms`;
    *   tune with `--delay-jitter-ms` if needed.
*   If YouTube challenges requests, rerun with cookies first before increasing worker count.

