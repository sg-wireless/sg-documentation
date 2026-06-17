# -- SG Wireless Documentation - Sphinx Configuration --
#
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import datetime


def _env_id(name):
    """Return a normalized analytics ID from the environment.

    Treats empty strings and literal 'none'/'null'/'undefined' as disabled.
    """
    value = os.environ.get(name, "")
    if value is None:
        return ""

    text = str(value).strip()
    return "" if text.lower() in ("", "none", "null", "undefined") else text

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
    "sphinx_copybutton",
]

# -- Multi-version support -----------------------------------------------------
# The build script (build_versions.sh) sets SGW_CURRENT_VERSION when building
# each version tag.  When unset we fall back to the release value (local builds).

import json as _json

_current_ver = os.environ.get("SGW_CURRENT_VERSION", f"v{release}")
_all_versions_json = os.environ.get("SGW_ALL_VERSIONS", _json.dumps([_current_ver]))
_all_versions = _json.loads(_all_versions_json)
_preview_versions_json = os.environ.get("SGW_PREVIEW_VERSIONS", "[]")
_preview_versions = _json.loads(_preview_versions_json)
_latest_ver = os.environ.get("SGW_LATEST_VERSION", _all_versions[0] if _all_versions else _current_ver)

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
    # Version selector data (populated by build_versions.sh via env vars)
    "current_version": _current_ver,
    "versions": _all_versions,
    "latest_version": _latest_ver,
    "preview_versions": _preview_versions,
    # Analytics env vars — set in Amplify to enable the corresponding loader.
    # Treat literal 'none'/'null'/'undefined' as disabled.
    "ga_measurement_id": _env_id("GA_MEASUREMENT_ID"),
    "gtm_container_id": _env_id("GTM_CONTAINER_ID"),
    "ga4_tag_id": _env_id("GA4_TAG_ID"),
}

# (sphinx-multiversion settings removed — see build_versions.sh)

# -- Options for intersphinx ---------------------------------------------------
# Link to upstream MicroPython docs so users can click through to standard
# library pages without us duplicating them.

intersphinx_mapping = {
    "micropython": ("https://docs.micropython.org/en/latest/", None),
    "python": ("https://docs.python.org/3/", None),
}

# -- Options for LaTeX / PDF output -------------------------------------------

latex_engine = "xelatex"

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
    # Use openany so chapters can start on any page (even or odd).
    # Without this the default "manual" class uses openright, inserting
    # a blank page whenever a chapter would fall on an even page.
    "classoptions": ",openany",
}

# -- Options for todo extension ------------------------------------------------

todo_include_todos = False

# -- Custom setup --------------------------------------------------------------

def setup(app):
    pass
