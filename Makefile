# Makefile for ICAT Hugo sites (2023 + 2025 + 2027)
#
# Targets:
#   make              — alias for make build
#   make build       — build 2023, 2025 and 2027 sites into html/<year>/
#   make build-2023  — build only the 2023 site
#   make build-2025  — build only the 2025 site
#   make serve       — run hugo server with live reload (development)
#   make clean       — remove html/<year>/ build output
#   make check       — verify no PHP, no unparsed templates, no absolute path prefixes
#   make help        — list available targets

HUGO        := hugo
HUGO_FLAGS  := --minify --cleanDestinationDir
DEST_ROOT   := $(CURDIR)/html

YEARS       := 2023 2025 2027

.PHONY: all build build-2023 build-2025 serve serve-2025 clean check help

all: build

# --- Per-year build -------------------------------------------------------

build-2023:
	cd 2023 && $(HUGO) $(HUGO_FLAGS) --destination $(DEST_ROOT)/2023
	bash 2023/flatten.sh $(DEST_ROOT)/2023

build-2025:
	cd 2025 && $(HUGO) $(HUGO_FLAGS) --destination $(DEST_ROOT)/2025
	bash 2025/flatten.sh $(DEST_ROOT)/2025

build-2027:
	cd 2027 && $(HUGO) $(HUGO_FLAGS) --destination $(DEST_ROOT)/2027
	bash 2027/flatten.sh $(DEST_ROOT)/2027

# --- Combined targets ------------------------------------------------------

build: build-2023 build-2025 build-2027

# --- Dev server -----------------------------------------------------------

serve:
	cd 2023 && $(HUGO) server --port 1313 --bind 0.0.0.0

serve-2025:
	cd 2025 && $(HUGO) server --port 1314 --bind 0.0.0.0

serve-2027:
	cd 2027 && $(HUGO) server --port 1315 --bind 0.0.0.0

# --- Cleanup --------------------------------------------------------------

clean:
	rm -rf $(DEST_ROOT)/2023 $(DEST_ROOT)/2025 $(DEST_ROOT)/2027

# --- Sanity checks --------------------------------------------------------

# Verify the build output contains no PHP, no unparsed Hugo template syntax,
# and no leaked baseURL prefixes (which would break file:// preview).
# Uses bash -c with explicit $$ escaping so $(year) substitutes correctly.
check:
	@bash -c '\
	fail=0; \
	for year in $(YEARS); do \
		out=$(DEST_ROOT)/$$year; \
		if [ ! -d "$$out" ]; then \
			echo "  [$$year] SKIP - no build at $$out (run make build first)"; \
			continue; \
		fi; \
		echo "  [$$year]"; \
		if grep -rIlq --include='*.html' --include='*.xml' "<?php" "$$out"; then \
			echo "    FAIL: PHP residual found"; \
			fail=1; \
		else \
			echo "    ok: no PHP"; \
		fi; \
		if grep -rIlqE --include='*.html' --include='*.xml' --include='*.css' --include='*.js' "\{\{[ ]*\(?[a-z]" "$$out"; then \
			echo "    FAIL: unparsed Hugo template in output"; \
			fail=1; \
		else \
			echo "    ok: no unparsed templates"; \
		fi; \
		if grep -rIlqE --include='*.html' "href=\"/$$year/|src=\"/$$year/" "$$out"; then \
			echo "    FAIL: baseURL prefix leaked into output (breaks file:// preview)"; \
			fail=1; \
		else \
			echo "    ok: no baseURL prefix leakage"; \
		fi; \
	done; \
	exit $$fail'

# --- Help ------------------------------------------------------------------

help:
	@echo "ICAT Hugo sites - Makefile targets:"
	@echo "  make build          Build 2023, 2025, and 2027 sites"
	@echo "  make build-2023     Build only the 2023 site"
	@echo "  make build-2025     Build only the 2025 site"
	@echo "  make build-2027     Build only the 2027 site (Bootstrap 5 template)"
	@echo "  make serve          Run hugo server for 2023 (live reload, port 1313)"
	@echo "  make serve-2025     Run hugo server for 2025 (port 1314)"
	@echo "  make serve-2027     Run hugo server for 2027 (port 1315)"
	@echo "  make clean          Remove html/2023, html/2025, html/2027 build output"
	@echo "  make check          Verify built output has no PHP, no template leftovers, no baseURL leaks"
	@echo "  make help           Show this help"
