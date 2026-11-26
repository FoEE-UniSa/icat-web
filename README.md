# ICAT Conference — website

Static website for the ICAT conference (International Conference on Information,
Communication and Automation Technologies), hosted by the Faculty of Electrical
Engineering, University of Sarajevo.

One Hugo project per edition, all built into a single tree:

```
2023/            Hugo source, ICAT 2023
2025/            Hugo source, ICAT 2025
2027/            Hugo source, ICAT 2027
html/            build output — this is what gets published
  2023/
  2025/
  2027/
Makefile         build, serve and check targets
AGENTS.md        conventions for editing the sites
```

## Requirements

Hugo 0.165.0 extended (or newer). No Node, no npm, no other tooling.

## Build

```bash
make build          # all editions
make build-2027     # one edition
```

Each build writes to `html/<year>/`. A post-build `flatten.sh` step is required:
Hugo 0.144+ emits `<name>.html/index.html` even when the permalink ends in
`.html`, and the script moves those up one level.

## Preview

```bash
make serve          # 2023 on :1313
make serve-2025     # 2025 on :1314
make serve-2027     # 2027 on :1315
```

Note: `hugo server` keeps the un-flattened directory layout, so relative links
break in the dev server. To preview exactly what ships, build first and serve
`html/` with any static file server.

## Checks

```bash
make check
```

Verifies the built output contains no PHP, no unparsed template syntax, and no
leaked `baseURL` prefixes.

## Conventions

All internal links are path-relative (`calls.html`, `images/logo.png`,
`css/site.css`) — never leading-slash, never `relURL`/`absURL`. The sites must
work when opened from `file://` and when served from any subdirectory.

See `AGENTS.md` for the full set of content, shortcode and CSS conventions.
