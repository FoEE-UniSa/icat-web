# ICAT Conference — website

Static website for the ICAT conference (International Conference on
Information, Communication and Automation Technologies), hosted by the Faculty
of Electrical Engineering, University of Sarajevo.

Three editions, one repository, one deployment:

```
2023/                   Hugo source, ICAT 2023 (archive)
2025/                   Hugo source, ICAT 2025 (archive)
2027/                   Hugo source, ICAT 2027 (current)
deploy/                 files copied to the root of the published site
.github/workflows/      GitHub Pages deployment
Makefile                build, serve and check targets
AGENTS.md               how the sites are put together and where to edit what
```

Build output is **not** committed. `make build` writes it to `html/`, and CI
rebuilds it on every push.

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

`hugo server` keeps the un-flattened directory layout, so relative links break
there. To preview exactly what ships, build first and serve `html/`:

```bash
make build-2027
cd html && python3 -m http.server 8099
```

## Deploy

Pushing to `main` runs `.github/workflows/pages.yml`, which builds all three
editions and publishes them with GitHub Pages:

```
/            → redirects to /2027/
/2023/       → ICAT 2023
/2025/       → ICAT 2025
/2027/       → ICAT 2027
```

Pages must be enabled once in the repository settings, with **Source: GitHub
Actions**.

The `baseURL` passed to Hugo comes from `actions/configure-pages`, so the same
sources work on `github.io/<repo>/` and on a custom domain without editing any
config.

Files in `deploy/` are copied to the site root during the build.
`deploy/404.html` uses a `__BASE__` placeholder that CI replaces with the real
base path. `deploy/robots.txt` blocks crawlers while this is a staging copy.

## Where to edit

For ICAT 2027 almost nothing is edited in templates.

| To change | Edit |
|-----------|------|
| Dates, city, edition, email, registration switch | `2027/data/conference.yaml` |
| Deadlines, news, committees, sponsors, stats, fees, previous editions, history | `2027/data/*.yaml` |
| Text of a page | `2027/content/<page>.md` |
| A keynote speaker | `2027/content/keynotes/<slug>.md` |
| Colours and typography | `2027/static/css/icat-2027.css` |
| How many items the home page shows | `[params.home]` in `2027/hugo.toml` |

ICAT 2023 and 2025 are archive editions; their content is plain markdown in
`2023/content/` and `2025/content/`.

`AGENTS.md` documents the data model, the shortcodes and the link conventions
in detail.

## Checks

```bash
make check
```

Verifies the built output contains no PHP, no unparsed template syntax, and no
leaked `baseURL` prefixes.

## Conventions

All internal links are path-relative (`calls.html`, `images/logo.png`,
`css/icat-2027.css`) — never leading-slash, never `relURL`/`absURL`. The sites
must work when opened from `file://` and when served from any subdirectory.
