# AGENTS.md — ICAT Conference Sites

Two Hugo static-site projects replacing the legacy PHP CMS that lived at
`html/2023/` and `html/2025/`. Both sites serve the ICAT (International
Conference on Information, Communication and Automation Technologies)
conference site for their respective years.

---

## Repository Layout

```
html-hugo/
├── AGENTS.md                       # this file
├── 2023/                           # ICAT 2023 Hugo site
│   ├── hugo.toml
│   ├── content/                    # markdown pages (headless news.md is included via shortcode)
│   ├── layouts/
│   │   ├── baseof.html             # page skeleton (head + nav + content + footer)
│   │   ├── _default/               # single.html, list.html (both just render .Content)
│   │   ├── partials/               # head.html, nav.html, footer.html
│   │   ├── news/                   # news-section.html layout for /news.md
│   │   ├── _shortcodes/            # keynote, session, news-item, deadline, deadline-card, committee-section
│   │   └── 404.html
│   ├── static/                     # images/, docs/, style/icat-style.css + bootstrap-4.6.1
│   └── flatten.sh                  # post-build script (see Build Workflow)
├── 2025/                           # ICAT 2025 Hugo site — same structure, year-specific content
│   ├── hugo.toml
│   ├── content/
│   ├── layouts/
│   └── static/
└── html/                           # production export (built output)
    ├── 2023/                       # = hugo build of 2023/
    └── 2025/                       # = hugo build of 2025/
```

---

## Build Workflow

Both sites use Hugo 0.162.1+extended. Each produces a flat `.html` output
(matches old PHP URL pattern). Because Hugo 0.144+ emits `content/index.html`
inside subdirectories even when the permalink ends in `.html`, a post-build
flatten script moves those index files up one level.

To build a site:

```bash
cd html-hugo/2023            # or 2025
hugo --minify --destination ../html/2023
bash flatten.sh ../html/2023
```

`flatten.sh` walks the output dir and for every `<name>.html/index.html`
moves it to `<name>.html` and removes the empty directory. Without it the
URL `/calls.html` would actually serve `calls.html/index.html`.

---

## URL & Path Conventions

- All internal links are **path-relative with no leading slash**
  (`href="calls.html"`, `src="style/icat-style.css"`).
- This is so the site works opened directly as `file://` *or* served.
- Static assets live under Hugo `static/` (served from site root).
- Bootstrap 4.6.1 is the only CSS framework; no JS frameworks beyond jQuery
  (slim) bundled with Bootstrap.

When editing content or layouts:

- Internal page links use `foo.html` (not `/foo/`, not `/foo.html`).
- Image / doc / CSS / JS references use `images/foo.png`, `docs/foo.pdf`,
  `style/...` — relative to the page.
- Do **not** use `relURL`, `absURL`, or any helper that injects
  `baseURL`. The sites must preview correctly without a server.

---

## Permalinks & Front Matter

`hugo.toml` sets:

```toml
[permalinks.page]
  "/**" = "/:contentbasename.html"
```

This produces `content/calls.md` → `/calls.html` (flat). Combined with
`flatten.sh` the output directory mirrors the old PHP URL space.

Front matter is minimal:

```toml
---
title: "Page Title"
---
```

Special pages:

- `news.md` has `headless: true` and `layout: "news-section"` — Hugo does
  not emit a standalone `news.html`. It is only rendered through the
  `{{< news-section >}}` shortcode invoked from `_index.md`.
- `404.md` has `layout: "404"` for the custom 404.

---

## Shortcodes (shared pattern across both sites)

All shortcodes live in `layouts/_shortcodes/<name>.html`. They receive
parameters either via named arguments (`name="value"`) or via inner
content (`.Inner`). When a parameter may contain double quotes, escape
them as `&quot;` in the markdown and pipe through `safeHTML` in the
template.

Current shortcodes (in `2023/`; mirror to `2025/` when adding new ones):

| Shortcode | Purpose |
|-----------|---------|
| `{{< news-item >}}` | News entry on homepage (params: link, title, date, description) |
| `{{< deadline-card >}}` | Wrapper for a list of `{{< deadline >}}` items |
| `{{< deadline >}}` | Single dated line in `dates.md` (param: variant = danger/success/warning) |
| `{{< committee-section >}}` | Heading + `<ul>` of members (params: heading, members separated by `\|`) |
| `{{< keynote >}}` | Keynote speaker block (params: id, name, photo, talk, title, affiliation, website, email, date, time, room, bio, abstract) |
| `{{< session >}}` | Panel or workshop block (params: id, title, moderator, participants, date, time, room, abstract, photo, biography) |
| `{{< news-section >}}` | Wrapper for the news block on homepage (no params; just wraps the news partial) |

When adding a new shortcode:

1. Create `layouts/_shortcodes/<name>.html`.
2. Use `.Get "param"` for named args and `{{ .Inner }}` for inner content.
3. If content may contain HTML or escaped entities, pipe through `safeHTML`.
4. Test that parameters with spaces and quotes work — escape inner quotes
   as `&quot;` if needed.

---

## CSS Conventions (`static/style/icat-style.css`)

- Bootstrap 4.6.1 handles all layout, colors, spacing.
- Custom classes live in `icat-style.css`. Current custom classes:
  - `.text-shadow` — black 2px shadow on light-on-dark banner text
  - `.icat-banner` / `.icat-banner-text` — full-bleed banner styling
  - `.icat-menu` / `.nav-item` / `.dropdown-menu-black` — dark nav with
    white-on-black inversion on hover
  - `.speaker-photo` — `max-width: 200px` (used in keynote/panel/workshop
    images)
  - `.visa-map` — `width: 90%` (visa policy map image)
  - `.session-meta` — `font-style: italic` (used in `dates` and `session` shortcode)

Do not add new classes without checking the existing list first — many
"custom-looking" patterns are already Bootstrap utility classes.

---

## Content Authoring Rules

- Each page is its own markdown file in `content/`.
- Do not embed raw HTML inline unless it's structural (Bootstrap cards,
  speaker blocks). Use shortcodes where one exists.
- For repeating structures (committees, news, deadlines, sessions), always
  use the corresponding shortcode rather than copy-pasting HTML.
- Internal links between pages use the `.html` form: `[text](calls.html)`.
- Images and documents live in `static/` and are referenced by relative path:
  `![alt](images/foo.png)`.

---

## 2027 site: data-driven content

The 2027 project does not keep repeated records in markdown. They live in
`2027/data/` and are rendered on every page that needs them, so a value is
edited in one place only.

| File | Holds | Used by |
|------|-------|---------|
| `data/conference.yaml` | year, edition, dates, city, host, email, `registrationOpen` | header, hero, footer, `<title>`, meta description |
| `data/deadlines.yaml` | important dates | home + `/dates.html` |
| `data/news.yaml` | news items, sorted by date in the template | home |
| `data/committee.yaml` | `groups:` (committees) and `tpc:` | `/committees.html`, `/tpc_members.html` |
| `data/sponsors.yaml` | sponsor name, logo, link | home |

Keynotes are the exception: each speaker is a file under
`content/keynotes/` with YAML front matter, because each one gets its own page
at `/keynotes/<file>.html`. The list page is `content/keynotes/_index.md`
(`url: /keynotes.html`), rendered by `layouts/keynotes/list.html`.

How many items the home page shows is set in `hugo.toml`:

```toml
[params.home]
  keynotes = 3
  news = 5
  deadlines = 6
```

Shortcodes in use: `hero`, `section`, `card`, `keynotes-preview`, `news-list`,
`deadlines`, `committee-list`, `sponsor-grid`, `countdown`, `timeline-item`,
`panel`, `register-cta`.

### Adding a keynote

1. Create `content/keynotes/<slug>.md`.
2. Fill in `name`, `role`, `affiliation`, `talk`, optional `photo`, `website`,
   `email`, and `weight` (controls the order).
3. Put the biography and abstract in the body under `## Biography` and
   `## Abstract`.

### Relative links with nested pages

Keynote pages live one directory deep, so shared partials compute a prefix
with `partial "rel-prefix.html" .` and use it in every `href`/`src`. To link to
another page from a template use `partial "rel-url.html" (dict "page" $ "target" .)`.
Never hard-code `../` and never use `relURL`/`absURL` — the sites must keep
working from any base path.

---

## Editing Workflow

1. Edit markdown in `content/` or shortcodes in `layouts/_shortcodes/`.
2. Run `hugo --minify --destination ../html/<year>` from the site directory.
3. Run `bash flatten.sh ../html/<year>` to flatten output.
4. Open the resulting `.html` file directly with `file://` to verify
   (no browser preview, no server).
5. Check that no `<?php` references, no `{{`, no `/2023/` or `/2025/`
   absolute prefixes appear in the rendered HTML.
6. Update `html/<year>/` (the production export) — this is what gets
   uploaded to the actual server.

---

## What This Project Explicitly Does Not Have

- No PHP. All server-side logic is gone. Static files only.
- No database. News, deadlines and committee members live in markdown and
  YAML data files.
- No build pipeline beyond Hugo. No webpack, no PostCSS, no Tailwind.
- No analytics, no tracking, no JavaScript beyond Bootstrap's bundle.
- No server-rendered redirects. URL changes are permanent.

If a feature requires PHP or server-side processing, it does not belong
in this project — push it upstream or redesign.
