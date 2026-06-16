# ------------------------------------------------------------------------------
# helm-repository Makefile
# Wraps sx-helm for CI/CD and developer convenience.
#
# Usage:
#   make <target> [CHART=<name>] [VERSION=x.y.z] [DESC="..."]
#
# All targets that target a single chart require CHART=.
# Set INTERACTIVE=false (default when called via make) to skip all prompts.
# ------------------------------------------------------------------------------

# Load shared configuration so make variables mirror the script's defaults.
# Values can be overridden on the command line: make release VERSION=21.3.5
include .tools/config
export

# -- Tunables ------------------------------------------------------------------
CHART       ?=
VERSION     ?=
DESC        ?= publish stable update for the full repository
INTERACTIVE ?= false

SX          := ./sx-helm

# -- Phony declarations --------------------------------------------------------
.PHONY: help \
        list version \
        info test lint lint-all test-all schema \
        package package-all \
        release release-all publish publish-chart \
        archive archive-legacy \
        sync-pull sync-push \
        delete \
        _require-chart


# ------------------------------------------------------------------------------
# HELP
# ------------------------------------------------------------------------------

help:
	@echo ""
	@echo "helm-repository — available make targets"
	@echo ""
	@echo "  Info / discovery"
	@echo "    make list                           List all charts"
	@echo "    make version                        Print tool, oc and helm versions"
	@echo "    make info        CHART=<name>       Show chart metadata"
	@echo ""
	@echo "  Development (per chart)"
	@echo "    make test        CHART=<name>       helm template + helm lint"
	@echo "    make lint        CHART=<name>       helm lint only"
	@echo "    make lint-all                       Lint every chart"
	@echo "    make test-all                       Template + lint every chart"
	@echo "    make schema      CHART=<name>       Regenerate values.schema.json"
	@echo ""
	@echo "  Build"
	@echo "    make package     CHART=<name>       Commit, resolve deps, sign, package"
	@echo "    make package-all                    Package every chart"
	@echo ""
	@echo "  Release"
	@echo "    make release     CHART=<name>       Bump version, history row, upload to S3"
	@echo "                     [VERSION=x.y.z]"
	@echo "                     [DESC='...']"
	@echo "    make release-all [VERSION=x.y.z]    Release every chart + tag repo"
	@echo "                     [DESC='...']"
	@echo "    make publish                        Regenerate and push stable/noschema/current repos"
	@echo "    make publish-chart CHART=<name>     Release chart + publish all repos"
	@echo ""
	@echo "  Repository"
	@echo "    make archive                        Push OCP 14–20 archive repos"
	@echo "    make archive-legacy                 Push OCP 6–17 legacy repos"
	@echo "    make sync-pull                      S3 → local .reposync (download)"
	@echo "    make sync-push                      local .reposync → S3 (upload + delete)"
	@echo ""
	@echo "  Danger"
	@echo "    make delete      CHART=<name>       Delete chart from disk, git, and S3"
	@echo "                     [FORCE_DELETE=yes]"
	@echo ""
	@echo "  Variables"
	@echo "    INTERACTIVE=true|false  (default: false — no prompts when called via make)"
	@echo "    VERSION=x.y.z           Force version instead of auto-increment"
	@echo "    DESC='...'              Force release description"
	@echo "    FORCE_DELETE=yes        Skip delete confirmation"
	@echo ""


# ------------------------------------------------------------------------------
# INFO / DISCOVERY
# ------------------------------------------------------------------------------

list:
	@$(SX) list

version:
	@$(SX) version

info: _require-chart
	$(SX) $(CHART) info


# ------------------------------------------------------------------------------
# DEVELOPMENT
# ------------------------------------------------------------------------------

test: _require-chart
	INTERACTIVE=$(INTERACTIVE) $(SX) $(CHART) test

lint: _require-chart
	helm lint charts/$(CHART)

lint-all:
	INTERACTIVE=$(INTERACTIVE) $(SX) lint-all

test-all:
	INTERACTIVE=$(INTERACTIVE) $(SX) test-all

schema: _require-chart
	$(SX) $(CHART) schemagen


# ------------------------------------------------------------------------------
# BUILD
# ------------------------------------------------------------------------------

package: _require-chart
	INTERACTIVE=$(INTERACTIVE) $(SX) $(CHART) package

package-all:
	INTERACTIVE=$(INTERACTIVE) $(SX) package-all


# ------------------------------------------------------------------------------
# RELEASE
# ------------------------------------------------------------------------------

release: _require-chart
	INTERACTIVE=$(INTERACTIVE) VERSION=$(VERSION) DESC=$(DESC) \
	  $(SX) $(CHART) release $(VERSION) "$(DESC)"

release-all:
	INTERACTIVE=$(INTERACTIVE) VERSION=$(VERSION) DESC=$(DESC) \
	  $(SX) release auto

publish:
	$(SX) publish

publish-chart: _require-chart
	INTERACTIVE=$(INTERACTIVE) VERSION=$(VERSION) DESC=$(DESC) \
	  $(SX) $(CHART) publish


# ------------------------------------------------------------------------------
# REPOSITORY
# ------------------------------------------------------------------------------

archive:
	$(SX) archive

archive-legacy:
	$(SX) archiveLegacy

sync-pull:
	$(SX) syncfroms3

sync-push:
	$(SX) synctos3


# ------------------------------------------------------------------------------
# DANGER ZONE
# ------------------------------------------------------------------------------

delete: _require-chart
	INTERACTIVE=$(INTERACTIVE) FORCE_DELETE=$(FORCE_DELETE) \
	  $(SX) $(CHART) delete


# ------------------------------------------------------------------------------
# INTERNAL GUARD
# ------------------------------------------------------------------------------

_require-chart:
	@test -n "$(CHART)" || { \
	  echo ""; \
	  echo "  ERROR: CHART= is required for this target."; \
	  echo "  Example: make $(MAKECMDGOALS) CHART=cluster-nmstate"; \
	  echo ""; \
	  exit 1; \
	}
