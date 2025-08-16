# K8s The Hard Way Documentation

This directory contains the MkDocs configuration for generating a blog/documentation site about the **Kubernetes The Hard Way** learning journey.

## 📁 Directory Structure

```
k8s-thw-docs/
├── mkdocs.yml          # MkDocs configuration file
├── requirements.txt    # Python dependencies
├── docs/              # Markdown documentation files
│   ├── index.md       # Homepage content
│   └── about.md       # About page
├── .venv/             # Python virtual environment
└── site/              # Generated static site (after build)
```

## 🚀 Quick Start

### 1. Setup Environment
```bash
# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Development Server
```bash
# Start live development server
mkdocs serve

# Access at http://127.0.0.1:8000
```

### 3. Build Static Site
```bash
# Generate static site
mkdocs build

# Output will be in site/ directory
```

## 📝 Content Structure

The documentation is organized as follows:

- **Home (`index.md`)** - Main landing page with project overview
- **About (`about.md`)** - Information about the learning journey and setup

## 🎨 Theme Configuration

Currently using the `simple-blog` theme for a clean, blog-like appearance. The theme can be customized in `mkdocs.yml`.

## 📚 Adding Content

### Create New Pages
1. Add markdown files to the `docs/` directory
2. Update the `nav` section in `mkdocs.yml`
3. Content will automatically appear in the navigation

### Example Navigation Update
```yaml
nav:
 - Home: index.md
 - Setup: setup.md
 - Lessons Learned: lessons.md
 - About: about.md
```

## 🔧 Configuration

The site configuration is managed in `mkdocs.yml`:

```yaml
site_name: K8s The Hard Way
nav:
 - Home: index.md
 - About: about.md
theme:
  name: simple-blog
```

## 🚀 Deployment Options

### GitHub Pages
```bash
# Deploy to GitHub Pages
mkdocs gh-deploy
```

### Manual Deployment
```bash
# Build and copy site/ directory to your web server
mkdocs build
rsync -av site/ user@server:/var/www/html/
```

## 📋 Dependencies

Current Python dependencies (see `requirements.txt`):
- MkDocs - Static site generator
- Theme-specific packages

## 📚 Related Documentation

- [Main Project README](../README.md) - Complete project overview
- [Terraform Configuration](../terraform/) - Infrastructure setup
- [MkDocs Documentation](https://www.mkdocs.org/) - Official MkDocs guide

---

**Purpose:** Document the learning journey, challenges, and insights gained while completing Kubernetes The Hard Way with automated infrastructure provisioning.
