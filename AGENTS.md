# AGENTS.md — ICAT Conference Sites

Three Hugo projects in one repository, deployed together as one site.

| Edition | Source | Stack | Content model |
|---------|--------|-------|---------------|
| ICAT 2023 | `2023/` | Hugo, Bootstrap 4 | markdown pages plus shortcodes |
| ICAT 2025 | `2025/` | Hugo, Bootstrap 4 | markdown pages plus shortcodes |
| ICAT 2027 | `2027/` | Hugo, Bootstrap 5 | repeated records in `data/*.yaml`, prose in markdown |

2023 and 2025 were converted from the old PHP CMS and are frozen: they are
archive copies of past editions. New work happens in `2027/`.

---

## Repository layout

```
.
├── 2023/                     ICAT 2023 Hugo project
├── 2025/                     ICAT 2025 Hugo project
├── 2027/                     ICAT 2027 Hugo project (current)
│   ├── hugo.toml
│   ├── content/              one markdown file per page
│   │   └── keynotes/         one file per speaker, each gets its own page
│   ├── data/                 YAML records (2027 only)
│   ├── layouts/
│   │   ├── baseof.html
│   │   ├── index.html        home page
│   │   ├── 404.html
│   │   ├── keynotes/         list and single layouts for speakers
│   │   ├── _default/single.html
│   │   ├── partials/         navbar, footer, cards, relative-link helpers
│   │   └── shortcodes/
│   ├── static/               css/, js/, images/, vendored Bootstrap 5
│   └── flatten.sh            post-build step
├── deploy/                   files copied to the root of the published site
│   ├── index.html            redirects / to /2027/
│   ├── 404.html              uses a __BASE__ placeholder, filled by CI
│   └── robots.txt
├── .github/workflows/        GitHub Pages deployment
├── Makefile
├── README.md
└── AGENTS.md
```

---

## Requirements and build

Hugo 0.165.0 extended. Nothing else — no Node, no npm.

```bash
make build          # 2023, 2025 and 2027
make build-2027     # one edition
```

Each build writes to `html/<year>/`. **That directory is not committed**; it is
rebuilt by CI on every push. `make clean` removes it.

`flatten.sh` is mandatory and runs automatically in the Makefile. Hugo 0.144+
emits `<name>.html/index.html` even when the permalink ends in `.html`, so the
script moves those up one level, at any depth.

The Makefile prefix is `hugo`, so a Hugo binary must be on `PATH`.

---

## Deploy

Pushing to `main` runs `.github/workflows/pages.yml`:

1. builds the three editions with `--baseURL` taken from
   `actions/configure-pages`, so nothing needs editing when the domain changes;
2. copies `deploy/` over the build, substituting `__BASE__` in `404.html`;
3. uploads the `dist/` artifact and publishes it with GitHub Pages.

```
/            redirects to /2027/
/2023/       ICAT 2023
/2025/       ICAT 2025
/2027/       ICAT 2027
```

Pages must be enabled once in the repository settings with **Source: GitHub
Actions**. `deploy/robots.txt` currently blocks crawlers because the github.io
copy is a staging site; switch it to `Allow: /` when the real domain goes live.

---

## URL and path conventions

All internal links are **path-relative**. Never a leading slash, never
`relURL`, never `absURL` — the sites must work from `github.io/<repo>/`, from a
custom domain, and from `file://`.

```html
<a href="calls.html">            <!-- same directory -->
<img src="images/logo.png">
```

Regular pages get a flat URL (`content/about.md` → `/about.html`). Keynote
detail pages are nested (`content/keynotes/foo.md` → `/keynotes/foo.html`), so
shared partials cannot hard-code link prefixes.

Two helpers exist for this and must be used instead of manual `../`:

```gotemplate
{{/* in partials and layouts, . is the page */}}
{{ $p := partial "rel-prefix.html" . }}
<a href="{{ $p }}calls.html">...</a>

{{/* in shortcodes, . is the shortcode context — pass .Page */}}
{{ $p := partial "rel-prefix.html" .Page }}

{{/* link to another page from a template */}}
{{ partial "rel-url.html" (dict "page" $ "target" $item) }}
```

---

## Editing the 2027 edition

### Where something lives

| To change | Edit |
|-----------|------|
| Conference dates, city, edition number, email, host | `2027/data/conference.yaml` |
| Whether the site is in CFP / review / programme / live / past phase | `phase` in `2027/data/conference.yaml` |
| Whether the Register button is shown | `registrationOpen` in `2027/data/conference.yaml` |
| Important dates | `2027/data/deadlines.yaml` |
| News items on the home page | `2027/data/news.yaml` |
| Committees and TPC | `2027/data/committee.yaml` |
| The four numbers under "Fifty years of ICAT" | `2027/data/stats.yaml` |
| Registration fees | `2027/data/fees.yaml` |
| Round tables, current and past | `2027/data/panels.yaml` |
| Sponsors and technical co-sponsors | `2027/data/sponsors.yaml` |
| Previous editions and their IEEE Xplore links | `2027/data/editions.yaml` |
| The "A brief history" timeline | `2027/data/history.yaml` |
| How many keynotes, news and deadlines the home page shows | `[params.home]` in `2027/hugo.toml` |
| Home page composition | `2027/content/_index.md` |
| Text of any inner page | `2027/content/<page>.md` |
| A keynote speaker | `2027/content/keynotes/<slug>.md` |
| Navigation structure | `2027/layouts/partials/navbar.html` |
| Footer | `2027/layouts/partials/footer.html` |
| Colours, spacing, typography | `2027/static/css/icat-2027.css` (tokens at the top) |
| Theme toggle, countdown, reveal-on-scroll | `2027/static/js/icat-2027.js` |

### Data files

Every record used on more than one page lives in `2027/data/`. Edit the value
once; every page that shows it updates.

| File | Shape |
|------|-------|
| `conference.yaml` | single object: `year`, `edition`, `startDate`, `endDate`, `dates`, `city`, `hostName`, `phase`, `registrationOpen`, … |
| `deadlines.yaml` | list of `{label, date, due, variant, note}` |
| `news.yaml` | list of `{date, title, link, description}`, newest first |
| `committee.yaml` | `groups:` and `tpc:`, each a list of `{heading, members: [{name, affiliation}]}` |
| `stats.yaml` | list of `{value, label}` |
| `fees.yaml` | `categoryLabel`, `earlyLabel`, `lateLabel`, `note`, and `categories: [{name, early, late}]` |
| `panels.yaml` | list of `{year, title, moderators, panelists}`; `pending: true` renders as "Details to be announced" |
| `sponsors.yaml` | `technical:` and `sponsors:`, each with `enabled`, `heading`, optional `lede` and `note`, and `items: [{name, logo, url}]` |
| `editions.yaml` | list of `{year, edition, kind, dates, city, url, xplore, archive}` |
| `history.yaml` | list of `{year, text}`; `text` is markdown |

`due` in `deadlines.yaml` is an ISO date used for sorting and for dimming
entries that have passed. `date` is what visitors read and may be vaguer.

### Keynotes are pages, not data

Each speaker is a file, because each one needs a biography and an abstract at
its own URL.

```yaml
---
title: Ada Lovelace
name: Ada Lovelace
role: Professor
affiliation: Analytical Engines Institute
talk: Notes on the Analytical Engine
weight: 1              # order in the list and on the home page
photo: images/ada.jpg  # optional
website: https://example.org   # optional
email: ada@example.org         # optional
---

## Biography

...

## Abstract

...
```

`photo` is optional. Without it the card and the page show a neutral person
icon in the same box the photo would occupy.

The list page is `2027/content/keynotes/_index.md`, which keeps the flat URL
`/keynotes.html` through `url:` in its front matter.

### Registration

Registration is handled through the conference submission system, not a
separate form, so `/registration.html` states that and shows the fee table
instead of a signup. `registrationOpen` in `conference.yaml` unhides the
Register button in the navigation and the hero once the system is open.

### Conference phase

`phase` in `conference.yaml` changes the hero button; templates are never
edited for this.

| phase | hero button |
|-------|-------------|
| `cfp` | Call for papers |
| `review` | Important dates |
| `programme` | See the programme |
| `live` | Programme |
| `past` | Previous editions |

The countdown reads `startDate` and `endDate` on its own and switches to
"under way" and "has ended" without a rebuild.

### Shortcodes in use

| Shortcode | Purpose |
|-----------|---------|
| `{{< hero >}}` | The home page hero, driven entirely by `conference.yaml` |
| `{{< section >}}` | Section wrapper: eyebrow, heading, lede, `alt="true"` for the tinted background |
| `{{< card >}}` | One card in the "Beyond the main track" row |
| `{{< keynotes-preview >}}` | First N speakers from `content/keynotes/` |
| `{{< news-list >}}` | News from `data/news.yaml` |
| `{{< deadlines >}}` | Dates from `data/deadlines.yaml`; `all="true"` ignores the home limit |
| `{{< committee-list group="groups" >}}` | Committee block; `group="tpc"` for the TPC page |
| `{{< timeline-item >}}` | One row of the schedule |
| `{{< panel-list >}}` | Current round table plus the list of past ones from `data/panels.yaml` |
| `{{< stats >}}` | Numbers from `data/stats.yaml` |
| `{{< fee-table >}}` | Registration fees from `data/fees.yaml` |
| `{{< sponsors-section >}}` | Both sponsor groups, each behind its own switch |
| `{{< organizers >}}` | "Organized by" band |
| `{{< edition-list >}}` | The table on `/editions.html` |
| `{{< history >}}` | The timeline on `/about.html` |

Shortcode output is markdownified, so a template that starts a line with four
spaces of indentation will be rendered as a code block. Keep shortcode HTML at
column 0, as the existing ones do.

---

## Editing the 2023 and 2025 editions

These are archive copies. They use Bootstrap 4.6.1 and a single stylesheet,
`static/style/icat-style.css`. Content is markdown plus shortcodes in
`layouts/shortcodes/`:

| Shortcode | Purpose |
|-----------|---------|
| `{{< news-item >}}` | News entry on the home page |
| `{{< deadline-card >}}` | Wrapper for a list of `{{< deadline >}}` items |
| `{{< deadline >}}` | One dated line (`variant` = danger/success/warning) |
| `{{< committee-section >}}` | Heading plus a list of members separated by `\|` |
| `{{< keynote >}}` | Keynote speaker block |
| `{{< session >}}` | Panel or workshop block |

Their permalinks are flat (`"/**" = "/:contentbasename.html"`), so new pages in
those editions also live at the site root.

---

## Checks

```bash
make check
```

Verifies the built output has no PHP, no unrendered template syntax, and no
leaked `baseURL` prefix. It runs against `html/`, so build first.

Note that `hugo server` keeps the un-flattened directory layout, which breaks
the relative links. To see what actually ships, build and serve `html/`:

```bash
make build-2027
cd html && python3 -m http.server 8099
```

---

## What this project does not have

- No PHP. All server-side logic is gone. Static files only.
- No database. Records live in YAML files and markdown.
- No build pipeline beyond Hugo. No webpack, no PostCSS, no Tailwind.
- No analytics, no tracking, no JavaScript beyond Bootstrap's bundle and
  `icat-2027.js`.
- No server-side redirects. URL changes are permanent.
