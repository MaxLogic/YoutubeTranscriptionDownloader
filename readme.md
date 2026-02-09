# yttrans

[![Made with Delphi](https://img.shields.io/badge/Made%20with-Delphi-blue?style=flat-square&logo=delphi)](https://www.embarcadero.com/products/delphi)

A simple, fast command-line tool for downloading YouTube video transcripts.

yttrans acts as a lightweight wrapper around the powerful `yt-dlp` engine, focusing on one task: fetching the plain text of a video's subtitles without downloading the video itself.

## Features

*   **Transcript Focused:** Downloads only the subtitle track, not the entire video.
*   **Language Selection:** Specify the desired transcript language (e.g., `en`, `pl`, `de`).
*   **Flexible Output:** Print the transcript directly to the console or save it to a text file.
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
*   `[meta]` allows enabling/disabling each metadata line independently.
*   Auto-generated output files never overwrite existing files (`name.md`, `name (2).md`, ...).

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

### Command-Line Arguments & Options

Use `yttrans` for these options. `-meta` is not a `yt-dlp` flag.

| Argument / Option | Alias        | Description                                                                                             |
| ----------------- | ------------ | ------------------------------------------------------------------------------------------------------- |
| `<URL>`           |              | The full URL of the YouTube video. This is a **required** argument.                                     |
| `-l`, `--lang`    |              | The language code for the subtitles (e.g., `en`, `pl`). Defaults to `en` if not specified.                |
| `-o`, `--output`  |              | Output file path. If a directory path is given, yttrans uses sanitized title as `<title>.md` and avoids overwrite by adding suffix. |
| `-p`, `--prefix`  |              | Prefix for auto-generated file names. Separator comes from `settings.ini` key `default.prefix_separator`. |
| `-meta`, `--meta` |              | Prepends metadata before transcript text. Individual fields are controlled by `[meta]` switches in `settings.ini`. |
| `-keywords`       |              | Comma-separated keywords added to metadata section. Automatically enables `-meta`.                      |
| `-h`, `--help`    |              | Displays the help message and exits.                                                                    |

