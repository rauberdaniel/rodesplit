#!/bin/sh

# This script processes Rodecaster Pro multi-track WAV recordings by:
# 1. Extracting individual microphone channels from the multi-track WAV files
# 2. Converting each channel to FLAC format
# 3. Applying time correction via pitch stretching to correct for clock inaccuracy
# 4. Combining the processed segments into complete per-channel FLAC files
#
# This assumes that all POD*.WAV files in the current directory are
# consecutive files from a single recording. They will simply be concatenated

# RODECASTER PRO CHANNEL LAYOUT:
# 1  - Main Output - Left
# 2  - Main Output - Right
# 3  - Mic Channel 1
# 4  - Mic Channel 2
# 5  - Mic Channel 3
# 6  - Mic Channel 4
# 7  - USB Channel - Left
# 8  - USB Channel - Right
# 9  - Smartphone Channel - Left
# 10 - Smartphone Channel - Right
# 11 - Bluetooth Channel - Left
# 12 - Bluetooth Channel - Right
# 13 - Sound Pads Channel - Left
# 14 - Sound Pads Channel - Right

DEFAULT_TRACKS="mic1 mic2 mic3 mic4"
TIME_CORRECTION=1.000137037

TRACKS="${@:-$DEFAULT_TRACKS}"

# Create and clean temporary directory
mkdir -p .rodesplit
trap 'rm -rf .rodesplit' EXIT

# Exit if more than 4 tracks specified
if [ $(echo "$TRACKS" | wc -w) -gt 4 ]; then
    echo "Error: Maximum of 4 tracks allowed (mic channels)"
    exit 1
fi

# Initialize track counter
track_index=0

for t in $TRACKS; do
    echo "$t"
    echo "#$t" > .rodesplit/$t.txt

    # create time-corrected flac for this track from every file
    for f in POD*.WAV; do
        echo "$f"
        ffmpeg -n -hide_banner -loglevel error -i $f -af "pan=1|c0=c$((track_index+2)),atempo=$TIME_CORRECTION" -ac 1 .rodesplit/${f%.WAV}_$t.flac
        echo "file '.rodesplit/${f%.WAV}_$t.flac'" >> .rodesplit/$t.txt
    done

    # combine flacs of all files into single flac
    ffmpeg -hide_banner -loglevel error -f concat -i .rodesplit/$t.txt $t.flac

    # increase track index
    track_index=$((track_index + 1))
done
