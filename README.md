# Sensa Documentation

This project uses [MkDocs](https://www.mkdocs.org/) with the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme to build professional technical documentation.

## 📚 Getting Started

### Install dependencies

```bash
pip install - r requirements.txt
```

### Serve locally

```bash
mkdocs serve
```

Visit [http://127.0.0.1:8000](http://127.0.0.1:8000) to view the documentation.

### Build static site

```bash
mkdocs build
```

The static site will be generated in the `site/` directory.

## 🗂️ Project Structure

```
.
├── docs/             # Markdown source files
│   └── index.md      # Home page
├── site/             # Generated static site
├── mkdocs.yml        # MkDocs configuration
├── requirements.txt  # Python dependencies
└── README.md
```

## 🔗 Useful Links
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
