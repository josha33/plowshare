#!/bin/bash
#
# This file is part of Plowshare.
#
# Plowshare is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Plowshare is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Plowshare.  If not, see <http://www.gnu.org/licenses/>.
#

# Delete a file from file sharing servers.
#
# Dependencies: curl, getopt
#
# Web: http://code.google.com/p/plowshare
# Contact: Arnau Sanchez <tokland@gmail.com>.
#
set -e

VERSION="0.9.1"
MODULES="megaupload zshare"
OPTIONS="
HELP,h,help,,Show help info
GETVERSION,v,version,,Return plowdel version
QUIET,q,quiet,,Don't print debug messages
"


# This function is duplicated from download.sh
absolute_path() {
    local SAVED_PWD="$PWD"
    TARGET="$1"

    while [ -L "$TARGET" ]; do
        DIR=$(dirname "$TARGET")
        TARGET=$(readlink "$TARGET")
        cd -P "$DIR"
        DIR="$PWD"
    done

    if [ -f "$TARGET" ]; then
        DIR=$(dirname "$TARGET")
    else
        DIR="$TARGET"
    fi

    cd -P "$DIR"
    TARGET="$PWD"
    cd "$SAVED_PWD"
    echo "$TARGET"
}

# Get library directory
LIBDIR=$(absolute_path "$0")

source "$LIBDIR/lib.sh"
for MODULE in $MODULES; do
    source "$LIBDIR/modules/$MODULE.sh"
done

# Print usage
#
usage() {
    log_debug "Usage: plowdel [OPTIONS] [MODULE_OPTIONS] URL1 [[URL2] [...]]"
    log_debug
    log_debug "  Delete a file-link from a file sharing site."
    log_debug
    log_debug "  Available modules: $MODULES"
    log_debug
    log_debug "Global options:"
    log_debug
    debug_options "$OPTIONS" "  "
    debug_options_for_modules "$MODULES" "DELETE"
}

# Main
#

MODULE_OPTIONS=$(get_modules_options "$MODULES" DELETE)
eval "$(process_options "plowshare" "$OPTIONS $MODULE_OPTIONS" "$@")"

test "$HELP" && { usage; exit 2; }
test "$GETVERSION" && { echo "$VERSION"; exit 0; }
test $# -ge 1 || { usage; exit 1; }

RETVAL=0

for URL in "$@"; do
    MODULE=$(get_module "$URL" "$MODULES")

    if test -z "$MODULE"; then
        log_debug "Skip: no module for URL ($URL)"
        RETVAL=4
        continue
    fi

    FUNCTION=${MODULE}_delete
    log_debug "starting delete ($MODULE): $URL"
    $FUNCTION "${UNUSED_OPTIONS[@]}" "$URL" || RETVAL=5
done

exit $RETVAL
