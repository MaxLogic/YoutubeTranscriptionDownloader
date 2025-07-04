# YouTrans

[![Made with Delphi](https://img.shields.io/badge/Made%20with-Delphi-blue?style=flat-square&logo=delphi)](https://www.embarcadero.com/products/delphi)

A simple, fast command-line tool for downloading YouTube video transcripts.

YouTrans acts as a lightweight wrapper around the powerful `yt-dlp` engine, focusing on one task: fetching the plain text of a video's subtitles without downloading the video itself.

## Features

*   **Transcript Focused:** Downloads only the subtitle track, not the entire video.
*   **Language Selection:** Specify the desired transcript language (e.g., `en`, `pl`, `de`).
*   **Flexible Output:** Print the transcript directly to the console or save it to a text file.
*   **Clean Text:** Automatically parses the SRT subtitle format into clean, readable plain text.
*   **Lightweight:** A single, native executable with no runtime dependencies other than `yt-dlp`.

## Requirements

YouTrans requires **`yt-dlp.exe`** to function.

*   You must download `yt-dlp.exe` from the official [yt-dlp GitHub Releases page](https://github.com/yt-dlp/yt-dlp/releases/latest).
*   Place `yt-dlp.exe` in the **same directory** as `youtrans.exe`.

## Installation

1.  Download the latest `youtrans.exe` from the [Releases](https://github.com/your-username/your-repo/releases) page of this repository.
2.  Download `yt-dlp.exe` from its [official repository](https://github.com/yt-dlp/yt-dlp/releases/latest).
3.  Place both `youtrans.exe` and `yt-dlp.exe` in the same folder.
4.  (Optional) For easy access from anywhere, add this folder to your system's `PATH` environment variable.

## Usage

The basic command structure is:

```bash
youtrans <URL> [options]
```

### Examples

**1. Get a transcript in English and print it to the console:**

```bash
youtrans "https://www.youtube.com/watch?v=dQw4w9WgXcQ" -l en
```

**2. Get a transcript in Polish and save it to a file:**

```bash
youtrans "https://www.youtube.com/watch?v=some_video_id" -l pl -o "C:\Transcripts\MyTranscript.txt"
```

**3. Get the default English transcript and save it to a file in the current directory:**
*(The `-l` flag defaults to `en` if omitted)*

```bash
youtrans "https://www.youtube.com/watch?v=another_video_id" -o transcript.txt
```

**4. Display the help message:**

```bash
youtrans -h
```

### Command-Line Arguments & Options

| Argument / Option | Alias        | Description                                                                                             |
| ----------------- | ------------ | ------------------------------------------------------------------------------------------------------- |
| `<URL>`           |              | The full URL of the YouTube video. This is a **required** argument.                                     |
| `-l`, `--lang`    |              | The language code for the subtitles (e.g., `en`, `pl`). Defaults to `en` if not specified.                |
| `-o`, `--output`  |              | The full path for the output text file. If omitted, the transcript is printed to the standard output (console). |
| `-h`, `--help`    |              | Displays the help message and exits.                                                                    |

