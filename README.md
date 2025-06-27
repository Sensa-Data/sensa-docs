# Sensa-docs Documentation
This project's aim is to provide comprehensive documentation of Sensa technical issues for public and private uses.

## 📚 Getting Started

### Install dependencies

```bash
pip install -r requirements.txt
```

### Serve locally

```bash
mkdocs serve -f mkdocs.public.yml # public docs
```
or 
```bash
mkdocs serve -f mkdocs.private.yml # private docs
```

Visit [http://127.0.0.1:8000](http://127.0.0.1:8000) to view the documentation.

### Build static site

```bash
mkdocs build -f mkdocs.public.yml # public docs
```
or
```bash
mkdocs build -f mkdocs.private.yml # private docs
```

The static site will be generated in the `site-public/` or `site-private/` directory according to your command.

## 🗂️ Project Structure

```
.
├── docs-private/      # Private Markdown docs
├── docs-public/       # Public Markdown docs (Python package)
├── site-private/      # Generated private static site
├── site-public/      # Generated public static site
├── mkdocs.private.yml # MkDocs config for private docs
├── mkdocs.public.yml  # MkDocs config for public docs
├── requirements.txt   # Python dependencies
└── README.md
```

## 🛠️ Developer Guide

### 1. Editing Documentation

- Edit or add Markdown files in `docs-private/` or `docs-public/` as needed.
- Add images to the respective `images/` folder.
- Update navigation in `mkdocs.private.yml` or `mkdocs.public.yml`.

### 2. Custom Styles

- Edit `docs-private/stylesheets/custom.css` to customize the look and feel.

### 3. Testing Your Changes

- Run `mkdocs serve -f mkdocs.private.yml` or `mkdocs.public.yml` to preview changes.
- Check the output in `site-private/` or `site-public/`.

### 4. Adding Dependencies

- Add Python dependencies to `requirements.txt`.
- Run `pip install -r requirements.txt` after changes.

### 5. Building for Production

- Use the appropriate config file to build:
  - Private: `mkdocs build -f mkdocs.private.yml`
  - Public: `mkdocs build -f mkdocs.public.yml`

## 🔗 Useful Links

- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [MkDocs Documentation](https://www.mkdocs.org/)
