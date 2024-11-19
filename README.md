# Rode Merge - Rodecaster Pro Multitrack Processor

A shell script for processing and merging multitrack WAV recordings from the Rodecaster Pro podcast recorder into single-track time-corrected FLAC files.

## Prerequisites

- `ffmpeg` with FLAC support must be installed on your system
- Rodecaster Pro multitrack WAV recordings (POD*.WAV files)

## Installation

1. Download the `rodesplit.sh` script
2. Make it executable:
```bash
chmod +x rodesplit.sh
```

## Usage

1. Place the script in the same directory as your Rodecaster Pro WAV files (POD*.WAV)
2. Run the script:

Basic usage (processes all 4 mic channels):
```bash
./rodesplit.sh
```

Process specific channels:
```bash
./rodesplit.sh host guest
```
Processes only the mic1 and mic2 channels and applies the filenames "host" and "guest"

## Features

- Extracts individual microphone channels from multitrack recordings
- Converts audio to FLAC format for better compression
- Applies time correction to fix clock inaccuracy issues
- Automatically concatenates multiple recording segments
- Supports processing up to 4 microphone channels
- Cleans up temporary files after processing

## Channel Layout Reference

The Rodecaster Pro uses the following channel layout:
1. Main Output - Left
2. Main Output - Right
3. Mic Channel 1
4. Mic Channel 2
5. Mic Channel 3
6. Mic Channel 4
7. USB Channel - Left
8. USB Channel - Right
9. Smartphone Channel - Left
10. Smartphone Channel - Right
11. Bluetooth Channel - Left
12. Bluetooth Channel - Right
13. Sound Pads Channel - Left
14. Sound Pads Channel - Right

## Output

The script creates individual FLAC files for each processed microphone channel:
- `mic1.flac`
- `mic2.flac`
- `mic3.flac`
- `mic4.flac`

## Notes

- The script assumes all POD*.WAV files in the directory are from the same recording session
- A maximum of 4 tracks (the microphone channels) can be processed at once
- Temporary files are automatically cleaned up after processing
