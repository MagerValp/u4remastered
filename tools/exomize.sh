#!/bin/bash
#
# Compress a prg or bin file with exomizer.


# Exit status constants.

declare -ri EX_OK=0
declare -ri EX_USAGE=64         # The command was used incorrectly.
declare -ri EX_DATAERR=65       # Input data was incorrect in some way.
declare -ri EX_NOINPUT=66       # Input file did not exist or wasn't readable.
declare -ri EX_NOUSER=67        # The user specified did not exist.
declare -ri EX_NOHOST=68        # The host specified did not exist.
declare -ri EX_UNAVAILABLE=69   # A service is unavailable.
declare -ri EX_SOFTWARE=70      # An internal software error has been detected.
declare -ri EX_OSERR=71         # An operating system error has been detected.
declare -ri EX_OSFILE=72        # Some system file is unavailable.
declare -ri EX_CANTCREAT=73     # A specified output file cannot be created.
declare -ri EX_IOERR=74         # An error occurred while doing I/O.
declare -ri EX_TEMPFAIL=75      # Temporary failure.
declare -ri EX_PROTOCOL=76      # Remote protocol failure.
declare -ri EX_NOPERM=77        # Required permission missing.
declare -ri EX_CONFIG=78        # Something was unconfigured or misconfigured.


# Exit with status and an error message.

function die() {
    local exit_status="$1"
    local message="$2"
    
    echo "$message" 1>&2
    exit "$exit_status"
}


function main() {
    # Arguments
    if [[ $# -ne 2 ]]; then
        die $EX_USAGE "Usage: $(basename "$0") source target"
    fi
    
    local source="$1"
    local target="$2"
    
    # Create a temp dir.
    tmpdir=$(mktemp -d -t exomize)
    
    # If the source is a .prg file don't compress the load address.
    if [[ "$source" == *.prg ]]; then
        if err=$(dd if="$source" of="$tmpdir/loadaddr" bs=2 count=1 2>&1); then
            :
        else
            echo "$err" >&2
            rm -rf "$tmpdir"
            return $EX_CANTCREAT
        fi
        exomizer raw -q -c -m 256 -o "$tmpdir/compressed" "$source,2"
        cat "$tmpdir/loadaddr" "$tmpdir/compressed" > "$target"
    else
        exomizer raw -q -c -m 256 -o "$target" "$source"
    fi
    
    # Clean up.
    rm -rf "$tmpdir"
    
    return $EX_OK
}

main "$@"
