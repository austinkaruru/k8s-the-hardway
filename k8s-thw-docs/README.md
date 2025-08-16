# K8s The Hard Way - Documentation Site

A modern, edgy documentation blog built with Material for MkDocs to document my journey through Kubernetes The Hard Way with Infrastructure as Code.

## 🎨 Theme Features

### Modern, Edgy Design
- **Black & Cyan color scheme** for a contemporary tech aesthetic
- **Kubernetes logo** with animated breathing glow effect
- **Modern typography** using Inter and JetBrains Mono fonts
- **Dark/Light mode** with enhanced dark theme
- **Gradient text effects** and modern shadows
- **Responsive design** optimized for all devices

### Advanced Features
- **Instant navigation** with prefetching for lightning-fast browsing
- **Enhanced search** with suggestions and highlighting
- **Code copy buttons** with syntax highlighting
- **Tabbed content** for multi-platform instructions
- **Modern admonitions** with gradient backgrounds
- **Feedback system** for page helpfulness
- **Minification** for optimal performance

## 📁 Directory Structure

```
k8s-thw-docs/
├── docs/                          # Documentation content
│   ├── index.md                   # Homepage
│   ├── setup/                     # Getting started guides
│   │   ├── prerequisites.md       # Multi-OS setup instructions
│   │   ├── gcp-setup.md          # GCP project and backend setup
│   │   └── ssh-setup.md          # SSH configuration
│   ├── infrastructure/            # Terraform and IaC content
│   │   ├── terraform-overview.md  # Why Terraform and architecture
│   │   ├── terraform-deployment.md # Step-by-step deployment
│   │   └── validation.md         # Infrastructure testing
│   ├── kubernetes/                # Kubernetes setup journey
│   │   └── manual-setup.md       # Starting the hard way
│   ├── img/                       # Images and assets
│   │   └── favicon.ico           # Kubernetes logo favicon
│   └── stylesheets/              # Custom CSS
│       └── modern-edgy-style.css # Modern theme customizations
├── mkdocs.yml                     # Site configuration
├── requirements.txt               # Python dependencies
└── README.md                      # This file
```

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- pip package manager

### Installation

1. **Navigate to the docs directory:**
   ```bash
   cd k8s-thw-docs
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Start the development server:**
   ```bash
   python -m mkdocs serve --dev-addr=0.0.0.0:8000
   ```

4. **Open your browser:**
   Navigate to `http://localhost:8000/k8s-the-hardway/`

## 🎯 Content Sections

### Getting Started
- **Prerequisites**: Multi-OS installation guides with tabbed content
- **GCP Setup**: Project creation, service accounts, and GCS backend
- **SSH Configuration**: Key generation and access setup

### Infrastructure Journey
- **Terraform Overview**: Architecture and state management strategy
- **Deployment Process**: Step-by-step infrastructure provisioning
- **Validation**: Testing and verification procedures

### The Hard Way Begins
- **Manual Setup**: Starting the Kubernetes journey
- **Certificate Authority**: PKI and security setup
- **Control Plane**: Master node configuration
- **Worker Nodes**: Worker node setup and joining
- **Victory Lap**: Cluster validation and testing

### Lessons & Reflections
- **What I Learned**: Key insights and discoveries
- **Troubleshooting**: Common issues and solutions
- **Tips & Tricks**: Best practices and recommendations

## 🛠️ Theme Configuration

### Material Theme Setup
The site uses a heavily customized Material theme:

```yaml
theme:
  name: material
  palette:
    - scheme: default
      primary: black
      accent: cyan
    - scheme: slate
      primary: black
      accent: cyan
  font:
    text: Inter
    code: JetBrains Mono
  logo: img/favicon.ico
  favicon: img/favicon.ico
  features:
    - navigation.instant
    - navigation.instant.prefetch
    - search.suggest
    - content.code.copy
    - content.code.annotate
```

### Custom CSS Features
- **Breathing logo animation** with bright cyan glow
- **Modern gradients** and shadow effects
- **Enhanced code blocks** with better syntax highlighting
- **Responsive typography** optimized for readability
- **Dark mode enhancements** with proper contrast

### Plugins Used
- **Search**: Enhanced search with suggestions
- **Minify**: HTML/CSS/JS optimization for performance

## 📝 Content Creation

### Writing Guidelines
- Use **personal, conversational tone** for blog-like feel
- Include **code examples** with proper syntax highlighting
- Add **admonitions** (tips, warnings, notes) for important information
- Use **tabbed content** for multi-platform instructions
- Include **screenshots** and diagrams where helpful

### Markdown Extensions
The site supports advanced Markdown features:
- **Code highlighting** with line numbers and copy buttons
- **Tabbed content** for organizing information
- **Admonitions** for callouts and warnings
- **Tables** with modern styling
- **Footnotes** and **smart typography**
- **Emoji support** for personality

## 🚀 Deployment Options

### GitHub Pages
```bash
# Build and deploy to GitHub Pages
mkdocs gh-deploy
```

### Manual Build
```bash
# Build static site
mkdocs build

# Output will be in site/ directory
```

### Docker (Optional)
```dockerfile
FROM python:3.9-slim
WORKDIR /docs
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000"]
```

## 🔧 Development

### Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Start with live reload
python -m mkdocs serve --dev-addr=0.0.0.0:8000

# Build for production
mkdocs build
```

### Adding Content
1. Create new `.md` files in appropriate `docs/` subdirectory
2. Add to navigation in `mkdocs.yml`
3. Use front matter for metadata if needed
4. Test locally before committing

### Custom Styling
- Edit `docs/stylesheets/modern-edgy-style.css` for theme changes
- Use CSS custom properties for consistent theming
- Test in both light and dark modes
- Ensure mobile responsiveness

## 📊 Performance Features

### Optimization
- **Minified HTML/CSS/JS** for faster loading
- **Optimized images** and assets
- **Efficient navigation** with instant loading
- **Search indexing** for quick content discovery

### Modern Web Standards
- **Responsive design** for all screen sizes
- **Accessible** color contrast and navigation
- **SEO optimized** with proper meta tags
- **Progressive enhancement** for better UX

## 🎨 Design Philosophy

### Modern & Edgy
- **Contemporary color palette** (black/cyan) for tech aesthetic
- **Clean typography** with modern font choices
- **Subtle animations** that enhance without distracting
- **Professional yet personal** tone and styling

### User Experience
- **Fast loading** with minification and optimization
- **Mobile-first** responsive design
- **Intuitive** structure and search functionality
- **Engaging** visual elements and interactions

## 📋 Dependencies

Current Python dependencies (see `requirements.txt`):
- **mkdocs** - Static site generator
- **mkdocs-material** - Material Design theme
- **pymdown-extensions** - Advanced Markdown features
- **mkdocs-minify-plugin** - Performance optimization

## 🤝 Contributing

### Content Guidelines
- Follow the established tone and style
- Include practical examples and code snippets
- Add proper attribution for external resources
- Test all code examples before publishing

### Technical Contributions
- Follow existing CSS organization and naming
- Test changes in both light and dark modes
- Ensure mobile compatibility
- Update documentation for new features

## 📚 Related Documentation

- [Main Project README](../README.md) - Complete project overview
- [Terraform Configuration](../terraform/) - Infrastructure setup
- [MkDocs Documentation](https://www.mkdocs.org/) - Official MkDocs guide
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) - Theme documentation

---

**Built with ❤️ using Material for MkDocs**

*Documenting the journey from infrastructure provisioning to Kubernetes mastery, one step at a time.*
