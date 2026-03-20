# SG Wireless Documentation

Sphinx-based documentation for SG Wireless products, replacing the legacy
WordPress site at docs.sgwireless.com.

## Quick Start

```bash
pip install -r requirements.txt
make html
# open _build/html/index.html
```

## PDF Build

```bash
make latexpdf
# output: _build/latex/SGWirelessDocumentation.pdf
```

## Multi-version Build

Tag releases with `vX.Y.Z`, then:

```bash
sphinx-multiversion . _build/html
```

## Deployment

The site is deployed automatically via AWS Amplify (see `amplify.yml`).
