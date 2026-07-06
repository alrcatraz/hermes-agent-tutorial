.PHONY: all serve build pdf clean

SHELL := /bin/bash
OUTDIR := build
DOCS := src
STYLES := styles
FILTERS := filters
PDF := $(OUTDIR)/hermes-agent-tutorial.pdf

# Ordered list of markdown source files (single source for both web & PDF)
SRC := \
	$(DOCS)/pdf-metadata.yaml \
	$(DOCS)/introduction.md \
	$(DOCS)/toc.md \
	$(DOCS)/volume-1/_divider.md \
	$(DOCS)/volume-1/01-introduction.md \
	$(DOCS)/volume-1/02-preparation.md \
	$(DOCS)/volume-1/03-installation.md \
	$(DOCS)/volume-1/04-initial-config.md \
	$(DOCS)/volume-1/05-gateway.md \
	$(DOCS)/volume-1/06-principles.md \
	$(DOCS)/volume-2/_divider.md \
	$(DOCS)/volume-2/07-multi-model.md \
	$(DOCS)/volume-2/08-memory.md \
	$(DOCS)/volume-2/09-gateway-interrupt.md \
	$(DOCS)/volume-2/10-searxng.md \
	$(DOCS)/volume-2/11-markitdown.md \
	$(DOCS)/volume-2/12-agent-customization.md \
	$(DOCS)/volume-3/_divider.md \
	$(DOCS)/volume-3/13-astra-intro.md \
	$(DOCS)/volume-3/14-astra-hub.md \
	$(DOCS)/volume-3/15-credentials.md \
	$(DOCS)/volume-3/16-knowledge-base.md \
	$(DOCS)/volume-3/17-work-principles.md \
	$(DOCS)/volume-3/18-context-anchor.md \
	$(DOCS)/volume-3/19-markitdown-extract.md \
	$(DOCS)/volume-3/20-camofox.md \
	$(DOCS)/volume-3/21-office-tools.md \
	$(DOCS)/volume-3/22-sre.md \
	$(DOCS)/volume-3/23-developer-guide.md \
	$(DOCS)/appendix/_divider.md \
	$(DOCS)/appendix/a-concepts.md \
	$(DOCS)/appendix/b-toolchain.md \
	$(DOCS)/appendix/c-config-example.md \
	$(DOCS)/appendix/d-faq.md

all: build pdf

# Web site (MkDocs)
build:
	@mkdir -p $(OUTDIR)
	uvx --with mkdocs-material mkdocs build --site-dir $(OUTDIR)/site

# Live preview
serve:
	uvx --with mkdocs-material mkdocs serve

# PDF (Pandoc + XeLaTeX)
pdf: $(PDF)

$(PDF): $(SRC)
	@mkdir -p $(OUTDIR)
	pandoc $^ \
		--pdf-engine=lualatex \
		--listings \
		--lua-filter=/home/alrcatraz/.hermes/templates/emoji-filter.lua \
		--lua-filter=$(FILTERS)/admonitions.lua \
		--lua-filter=$(FILTERS)/inline-code-bg.lua \
		--lua-filter=$(FILTERS)/diagram-path.lua \
		--highlight-style=tango \
		-V colorlinks=true \
		-V geometry:margin=1in \
		-H $(STYLES)/astra-doc-style.sty \
		-o $@
	@echo "PDF generated: $@"

clean:
	rm -rf $(OUTDIR)

## Diagrams — generate SVGs from DOT sources (local dot preferred, quickchart.io fallback)
diagrams:
	@echo "Regenerating diagrams from DOT sources..."
	@for dot in docs/diagrams/*.dot; do \
		name=`basename "$$dot" .dot`; \
		if command -v dot &>/dev/null; then \
			dot -Tsvg "$$dot" -o "docs/diagrams/$$name.svg" && echo "  (local) $$name.svg" || echo "  !! $$name.svg failed"; \
		else \
			code=`cat "$$dot" | python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read()))"`; \
			curl -sL -o "docs/diagrams/$$name.svg" -w "  %{http_code}" \
				"https://quickchart.io/graphviz?graph=$$code&format=svg&width=700"; \
			echo " $$name.svg"; \
		fi; \
	done
	@echo "Diagrams regenerated"
