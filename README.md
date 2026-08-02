# rofi-web-search
Rofi web search modi

**installation**

add `web-search.sh` to `/home/user/.config/rofi`, then add

```bash
configuration {
    modi: "web:~/.config/rofi/web-search.sh";
}
```

to `/home/user/.config/rofi/config.rasi`

**use**

type: `<prefix> <search>`

prefixes:

  g =   google;
  yt =  youtube;
  so =  stack overflow;
  gh =  github;
  rd =  reddit;
  ox =  oxford learner's dictionaries

*example: ox sweet pea  ->  oxford dictionary*
