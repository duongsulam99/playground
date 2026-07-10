FVM_CHECK := $(shell command -v fvm 2> /dev/null)

ifeq ($(strip $(FVM_CHECK)),)
	FLUTTER = flutter
else
	FLUTTER = fvm flutter
endif

.PHONY: help init get clean build repair fix

help:
	@echo "Available commands:"
	@echo "  make init       - Generate l10n from app_*.arb and get dependencies"
	@echo "  make get        - Get dependencies"
	@echo "  make run_build  - Run build_runner (Freezed + FlutterGen)"
	@echo "  make clean      - Flutter clean"

init:
	@./scripts/gen_l10n.sh
	@$(FLUTTER) pub get

get:
	@$(FLUTTER) pub get

clean:
	@$(FLUTTER) clean

repair:
	@$(FLUTTER) pub cache repair

# ============================================================
# Build the app (with code generation)
# ============================================================

build:
	@echo "Building..."
	@dart run build_runner clean
	@dart run build_runner build --delete-conflicting-outputs
	@echo "Build completed."

# ============================================================
# Fix warnings automatically
# ============================================================

fix:
	@echo "🔧 Fixing warnings..."
	@bash scripts/fix_warnings.sh
	@echo "✅ Warnings fixed"
