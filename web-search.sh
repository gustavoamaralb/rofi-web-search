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
    PREFIX=$(echo "$QUERY" | awk '{print $1}')

    # extracts the rest of the text (search term)
    RAW_TERM=$(echo "$QUERY" | cut -d' ' -f2-)

    # encodes the term and the entire query
    SEARCH_TERM=$(urlencode "$RAW_TERM")
    FULL_QUERY=$(urlencode "$QUERY")

    # the 'ox' prefix receives special handling: spaces become hyphens, apostrophes
    # are removed, and everything is converted to lowercase, following the
    # Oxford URL format for compound words and expressions
    OX_TERM=$(echo "$SEARCH_TERM" | sed 's/%27//g' | tr '+' '-' | tr '[:upper:]' '[:lower:]')

    case "$PREFIX" in
        g)  xdg-open "https://google.com/search?q=$SEARCH_TERM" ;;
        yt) xdg-open "https://youtube.com/results?search_query=$SEARCH_TERM" ;;
        so) xdg-open "https://stackoverflow.com/search?q=$SEARCH_TERM" ;;
        gh) xdg-open "https://github.com/search?q=$SEARCH_TERM" ;;
        rd) xdg-open "https://www.reddit.com/search/?q=$SEARCH_TERM" ;;
        ox) xdg-open "https://www.oxfordlearnersdictionaries.com/definition/english/$OX_TERM" ;;
        *)  xdg-open "https://google.com/search?q=$FULL_QUERY" ;;
    esac
    exit 0
fi

# defines the displayed message
echo "digite 'g, yt, so, gh, rd ou ox <busca>'
g = google
yt = youtube
so = stack overflow
gh = github
rd = reddit
ox = oxford learner's dictionaries"
