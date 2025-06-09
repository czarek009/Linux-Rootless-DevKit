# MkDocs

For full documentation visit [mkdocs.org](https://www.mkdocs.org).

## Commands

* `mkdocs new [dir-name]` - Create a new project.
* `mkdocs serve` - Start the live-reloading docs server.
* `mkdocs build` - Build the documentation site.
* `mkdocs -h` - Print help message and exit.

## Project layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        modules/  # Module related documentation (rust, ohmybash, go etc.)
        help/     # Mkdocs and Markdown tutorials

## How to Add a New Page in MkDocs

Adding a new page in MkDocs is easy and takes just 2 steps:

---

### 1. Create a new `.md` file in the `docs/` directory

For example:

```bash
touch docs/mypage.md
```

Then edit the file content:

```markdown
# My New Page

Welcome to the new page in your documentation!
```

---

### 2. Add the page to the navigation in `mkdocs.yml`

Open `mkdocs.yml` file and update the `nav` section:

```yaml
nav:
  - Home: index.md
  - My New Page: mypage.md
```

> 🔁 The order in `nav` controls the sidebar menu structure.

---
