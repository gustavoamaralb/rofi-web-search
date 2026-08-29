# Rofi web search modi

A [Rofi](https://github.com/davatorium/rofi) script mode that searches the web (or a specific site) straight from Rofi, using short prefixes to pick where the search goes.

## Requirements

- `rofi`
- `bash`
- `xdg-open` (usually provided by `xdg-utils`)

## Installation

1. Copy `web-search.sh` into `~/.config/rofi/` and make it executable:

   ```sh
   cp web-search.sh ~/.config/rofi/web-search.sh
   chmod +x ~/.config/rofi/web-search.sh
   ```

2. Add the `web` modi to your `~/.config/rofi/config.rasi`, pointing to the script:

   ```css
   configuration {
       modi: "web:~/.config/rofi/web-search.sh";
   }
   ```

   If you already have other modi configured, just append it to the list:

   ```css
   configuration {
       modi: "drun,web:~/.config/rofi/web-search.sh,run";
   }
   ```

3. Launch it directly with:

   ```sh
   rofi -show web
   ```

   or select it from the modi switcher (`Ctrl+Tab` by default) when running plain `rofi -show drun`.

## Usage

```
<prefix> <search terms>
```

| Prefix | Site                             |
| ------ | --------------------------------- |
| `g`    | Google                            |
| `yt`   | YouTube                           |
| `so`   | Stack Overflow                    |
| `gh`   | GitHub                            |
| `rd`   | Reddit                            |
| `ox`   | Oxford Learner's Dictionaries     |
| `pdb`  | RCSB Protein Data Bank            |
| `w`    | Wikipedia                         |
| `cb`   | Google search using the current clipboard content |

**Example:** typing `ox sweet pea` opens the Oxford dictionary entry for "sweet pea".

- Prefixes are case-insensitive (`G test` works the same as `g test`).
- Typing a prefix with no search terms (e.g. just `yt`) opens that site's homepage instead of an empty search.
- Typing a bare domain or a full URL (e.g. `github.com` or `https://github.com/rofi/rofi`) opens it directly instead of searching for it. This is a best-effort heuristic — a term that happens to look like a domain (e.g. `node.js`) will also be treated as one; prefix it (`g node.js`) to force a search instead.
- Typing text without a recognized prefix (e.g. `how to center a div`) falls back to a regular Google search for the whole query.
- Opening the modi with nothing typed shows the list of available prefixes as a hint message.
- `cb` requires `xclip` (X11) or `wl-paste` (Wayland, from `wl-clipboard`) to read the clipboard.
- `pdb` searches via a Google `site:rcsb.org` query, since RCSB's own search UI is a JS app with no simple shareable search link.

## License

[MIT](LICENSE)
