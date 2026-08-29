#!/usr/bin/env bash
# merges all arguments typed in Rofi into a single line
QUERY="$*"

# encodes the string for URLs: symbols (+, #, &, %, accents, etc.) become
# literal text in the search instead of breaking the URL or the shell
urlencode() {
    local string="$1" encoded="" hex
    for hex in $(printf '%s' "$string" | od -An -v -tx1); do
        case "$hex" in
            20) encoded+="+" ;;                                # space -> +
            2d|2e|5f|7e) encoded+="$(printf "\x$hex")" ;;     # - . _ ~ remain as they are
            3[0-9]|4[1-9a-f]|5[0-9a]|6[1-9a-f]|7[0-9a]) encoded+="$(printf "\x$hex")" ;; # letters and numbers
            *) encoded+="%${hex^^}" ;;                         # other symbols -> %XX
        esac
    done
    printf '%s' "$encoded"
}

if [ -n "$QUERY" ]; then
    # extracts the first word (prefix)
    PREFIX="${QUERY%% *}"

    # extracts the rest of the text (search term); empty if the query is
    # just the prefix with no term after it
    if [ "$PREFIX" = "$QUERY" ]; then
        RAW_TERM=""
    else
        RAW_TERM="${QUERY#* }"
    fi

    # encodes the term and the entire query
    SEARCH_TERM=$(urlencode "$RAW_TERM")
    FULL_QUERY=$(urlencode "$QUERY")

    # the "ox" prefix receives special handling: spaces become hyphens, apostrophes
    # are removed, and everything is converted to lowercase, following the
    # Oxford URL format for compound words and expressions
    OX_TERM=$(echo "$SEARCH_TERM" | sed 's/%27//g' | tr '+' '-' | tr '[:upper:]' '[:lower:]')

    # each known prefix has a homepage (used when only the prefix is typed,
    # with no search term) and a search URL
    case "$PREFIX" in
        g)  HOMEPAGE="https://google.com"
            SEARCH_URL="https://google.com/search?q=$SEARCH_TERM" ;;
        yt) HOMEPAGE="https://youtube.com"
            SEARCH_URL="https://youtube.com/results?search_query=$SEARCH_TERM" ;;
        so) HOMEPAGE="https://stackoverflow.com"
            SEARCH_URL="https://stackoverflow.com/search?q=$SEARCH_TERM" ;;
        gh) HOMEPAGE="https://github.com"
            SEARCH_URL="https://github.com/search?q=$SEARCH_TERM" ;;
        rd) HOMEPAGE="https://www.reddit.com"
            SEARCH_URL="https://www.reddit.com/search/?q=$SEARCH_TERM" ;;
        ox) HOMEPAGE="https://www.oxfordlearnersdictionaries.com"
            SEARCH_URL="https://www.oxfordlearnersdictionaries.com/definition/english/$OX_TERM" ;;
        *)  HOMEPAGE=""
            SEARCH_URL="https://google.com/search?q=$FULL_QUERY" ;;
    esac

    if [ -z "$RAW_TERM" ] && [ -n "$HOMEPAGE" ]; then
        xdg-open "$HOMEPAGE"
    else
        xdg-open "$SEARCH_URL"
    fi
    exit 0
fi
#dheg