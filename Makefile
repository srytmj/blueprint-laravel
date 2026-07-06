.PHONY: setup sync update deploy help

help:
	@echo ""
	@echo "Available commands:"
	@echo "  make setup    First time setup (name project, optional Laravel install)"
	@echo "  make sync     Sync stack from SRS/PRD into CLAUDE.md"
	@echo "  make update   Pull latest code from GitHub (force overwrite)"
	@echo "  make deploy   Run full deploy wizard (DB, S3, Cloudflare, services)"
	@echo ""

setup:
	bash setup.sh

sync:
	bash sync.sh

update:
	bash scripts/update.sh

deploy:
	sudo bash scripts/deploy.sh
