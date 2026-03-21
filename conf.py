# -- SG Wireless Documentation - Sphinx Configuration --
#
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import datetime

# -- Project information -------------------------------------------------------

project = "SG Wireless"
author = "SG Wireless"
copyright = f"{datetime.datetime.now().year}, SG Wireless - All Rights Reserved"

# The short X.Y version
version = "1.4"
# The full version, including alpha/beta/rc tags
release = "1.4.0"

# -- General configuration -----------------------------------------------------

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.intersphinx",
    "sphinx.ext.todo",
    "sphinx_rtd_theme",
]

# Try to load sphinx-multiversion for versioned builds (optional dependency)
try:
    import sphinx_multiversion
    extensions.append("sphinx_multiversion")
except ImportError:
    pass

templates_path = ["_templates"]
exclude_patterns = ["_build", ".venv", "Thumbs.db", ".DS_Store", "README.md"]

# The master toctree document
master_doc = "index"

# -- Options for HTML output ---------------------------------------------------

html_theme = "sphinx_rtd_theme"
html_theme_options = {
    "logo_only": True,

    "prev_next_buttons_location": "bottom",
    "style_external_links": False,
    "navigation_depth": 4,
    "collapse_navigation": False,
    "sticky_navigation": True,
    "includehidden": True,
    "titles_only": False,
}

html_static_path = ["_static"]
# Logo/favicon are handled by the custom header template
html_logo = "_static/logo-white.svg"
html_favicon = "_static/favicon.png"
html_css_files = ["custom.css"]

html_context = {
    "display_github": True,
    "github_user": "sg-wireless",
    "github_repo": "sg-documentation",
    "github_version": "main",
    "conf_py_path": "/",
}

# -- Options for sphinx-multiversion -------------------------------------------
# These settings control which git refs are built as separate doc versions.
# Only active when sphinx-multiversion is installed.

smv_tag_whitelist = r"^v\d+\.\d+\.\d+$"       # e.g. v1.3.0, v1.4.0
smv_branch_whitelist = r"^main$"                # also build the main branch
smv_remote_whitelist = r"^origin$"
smv_released_pattern = r"^refs/tags/v\d+\.\d+\.\d+$"
smv_outputdir_format = "{ref.name}"

# -- Options for intersphinx ---------------------------------------------------
# Link to upstream MicroPython docs so users can click through to standard
# library pages without us duplicating them.

intersphinx_mapping = {
    "micropython": ("https://docs.micropython.org/en/latest/", None),
    "python": ("https://docs.python.org/3/", None),
}

# -- Options for LaTeX / PDF output -------------------------------------------

latex_documents = [
    (
        master_doc,
        "SGWirelessDocs.tex",
        "SG Wireless Documentation",
        "SG Wireless",
        "manual",
    ),
]
latex_elements = {
    "papersize": "a4paper",
    "pointsize": "11pt",
}

# -- Options for todo extension ------------------------------------------------

todo_include_todos = False

# -- Custom setup --------------------------------------------------------------

def setup(app):
    pass
