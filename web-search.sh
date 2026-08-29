#!/usr/bin/env bash
# Rofi web search modi -- bsgustavoa (#dheg)
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

# reads the current clipboard content, on X11 or Wayland
read_clipboard() {
    if command -v wl-paste >/dev/null 2>&1; then
        wl-paste 2>/dev/null
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard -o 2>/dev/null
    fi
}

# first call, nothing typed yet: show the available prefixes as a hint
# instead of an empty list
if [ -z "$QUERY" ]; then
    echo -en "\0message\x1fg=Google  yt=YouTube  so=StackOverflow  gh=GitHub  rd=Reddit  ox=Oxford  pdb=RCSB PDB  w=Wikipedia  cb=search clipboard\n"
    exit 0
fi

# a full URL or a bare domain (e.g. "github.com" or "github.com/user/repo")
# is opened directly instead of being searched for
if [[ "$QUERY" =~ ^https?://[^[:space:]]+$ ]]; then
    xdg-open "$QUERY"
    exit 0
elif [[ "$QUERY" != *" "* && "$QUERY" =~ ^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/[^[:space:]]*)?$ ]]; then
    xdg-open "https://$QUERY"
    exit 0
fi

# extracts the rest of the text (search term); empty if the query is
# just the prefix with no term after it
if [[ "$QUERY" == *" "* ]]; then
    RAW_TERM="${QUERY#* }"
else
    RAW_TERM=""
fi

# extracts the first word (prefix); matching is case-insensitive
PREFIX="${QUERY%% *}"
PREFIX="${PREFIX,,}"

# encodes the term and the entire query
SEARCH_TERM=$(urlencode "$RAW_TERM")
FULL_QUERY=$(urlencode "$QUERY")

# the "ox" prefix receives special handling: spaces become hyphens, apostrophes
# are removed, and everything is converted to lowercase, following the
# Oxford URL format for compound words and expressions
OX_TERM=$(echo "$SEARCH_TERM" | sed 's/%27//g' | tr '+' '-' | tr '[:upper:]' '[:lower:]')

# "cb" searches Google using the current clipboard content instead of typed text
if [ "$PREFIX" = "cb" ]; then
    CLIP="$(read_clipboard)"
    if [ -n "$CLIP" ]; then
        xdg-open "https://google.com/search?q=$(urlencode "$CLIP")"
    else
        xdg-open "https://google.com"
    fi
    exit 0
fi

# each known prefix has a homepage (used when only the prefix is typed,
# with no search term) and a search URL
case "$PREFIX" in
    g)   HOMEPAGE="https://google.com"
         SEARCH_URL="https://google.com/search?q=$SEARCH_TERM" ;;
    yt)  HOMEPAGE="https://youtube.com"
         SEARCH_URL="https://youtube.com/results?search_query=$SEARCH_TERM" ;;
    so)  HOMEPAGE="https://stackoverflow.com"
         SEARCH_URL="https://stackoverflow.com/search?q=$SEARCH_TERM" ;;
    gh)  HOMEPAGE="https://github.com"
         SEARCH_URL="https://github.com/search?q=$SEARCH_TERM" ;;
    rd)  HOMEPAGE="https://www.reddit.com"
         SEARCH_URL="https://www.reddit.com/search/?q=$SEARCH_TERM" ;;
    ox)  HOMEPAGE="https://www.oxfordlearnersdictionaries.com"
         SEARCH_URL="https://www.oxfordlearnersdictionaries.com/definition/english/$OX_TERM" ;;
    pdb) HOMEPAGE="https://www.rcsb.org"
         # RCSB's own search UI is a JS app with no simple deep-link, so this
         # falls back to a site-restricted Google search
         SEARCH_URL="https://google.com/search?q=site:rcsb.org+$SEARCH_TERM" ;;
    w)   HOMEPAGE="https://en.wikipedia.org"
         SEARCH_URL="https://en.wikipedia.org/w/index.php?search=$SEARCH_TERM" ;;
    *)   HOMEPAGE=""
         SEARCH_URL="https://google.com/search?q=$FULL_QUERY" ;;
esac

if [ -z "$RAW_TERM" ] && [ -n "$HOMEPAGE" ]; then
    xdg-open "$HOMEPAGE"
else
    xdg-open "$SEARCH_URL"
fi
exit 0
