.PHONY: setup sync help

help:
	@echo ""
	@echo "Available commands:"
	@echo "  make setup    First time setup (name the project, create code/)"
	@echo "  make sync     Sync Stack section from docs/SRS.md into CLAUDE.md"
	@echo ""

setup:
	bash setup.sh

sync:
	bash sync.sh
