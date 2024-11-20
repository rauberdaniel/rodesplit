#!/usr/bin/env bash

# Set strict error handling
set -euo pipefail
IFS=$'\n\t'

# Script configuration
readonly DEFAULT_TRACKS=("mic1" "mic2" "mic3" "mic4")
readonly TIME_CORRECTION=1.000137037
readonly TEMP_DIR=".rodesplit"

# Help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [track_names...]

Process Rodecaster Pro multi-track WAV recordings.
If no track names are provided, defaults to: $(printf "%s " "${DEFAULT_TRACKS[@]}")

Channel Layout:
    1-2:   Main Output (L/R)
    3-6:   Mic Channels 1-4
    7-8:   USB Channel (L/R)
    9-10:  Smartphone Channel (L/R)
    11-12: Bluetooth Channel (L/R)
    13-14: Sound Pads Channel (L/R)
EOF
}

# Error handling function
error() {
    echo "Error: $1" >&2
    exit 1
}

# Check if required commands exist
check_dependencies() {
    local deps=(ffmpeg)
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            error "$dep is required but not installed"
        fi
    done
}

# Clean up function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Process a single track
process_track() {
    local track_name="$1"
    local track_index="$2"
    local track_file="$TEMP_DIR/$track_name.txt"

    echo "Processing track: $track_name"
    echo "#$track_name" > "$track_file"

    # Process each WAV file
    local wav_files
    wav_files=$(ls POD*.WAV 2>/dev/null) || error "No POD*.WAV files found"

    for wav_file in $wav_files; do
        echo "Processing file: $wav_file"
        local output_flac="${wav_file%.WAV}_${track_name}.flac"

        if ! ffmpeg -n -hide_banner -loglevel error \
            -i "$wav_file" \
            -af "pan=1|c0=c$((track_index+2)),atempo=$TIME_CORRECTION" \
            -ac 1 "$TEMP_DIR/$output_flac"; then
            error "Failed to process $wav_file"
        fi

        echo "file '$output_flac'" >> "$track_file"
    done

    # Combine all FLAC files
    if ! ffmpeg -hide_banner -loglevel error \
        -f concat -i "$track_file" \
        "$track_name.flac"; then
        error "Failed to combine FLAC files for $track_name"
    fi
}

main() {
    # Show help if requested
    if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
        show_help
        exit 0
    fi

    # Check dependencies
    check_dependencies

    # Set up cleanup trap
    trap cleanup EXIT

    # Create temp directory
    mkdir -p "$TEMP_DIR"

    # Get tracks to process
    if [ $# -eq 0 ]; then
        local tracks=("${DEFAULT_TRACKS[@]}")
    else
        local tracks=("$@")
    fi

    # Validate track count
    if [ "${#tracks[@]}" -gt 4 ]; then
        error "Maximum of 4 tracks allowed (mic channels)"
    fi

    # Process each track
    local track_index=0
    for track in "${tracks[@]}"; do
        process_track "$track" "$track_index"
        track_index=$((track_index + 1))
    done

    echo "Processing complete!"
}

main "$@"
