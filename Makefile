# Makefile for Zig project (no build.zig)

# Configuration
ZIG       := zig
MODE      := Debug # or ReleaseSafe / ReleaseFast / ReleaseSmall
SRC       := src/main.zig
OUT_DIR   := build
OUT_BIN   := $(OUT_DIR)/app
ZIG_TEST  := test/main_test.zig

.PHONY: all
all: build

.PHONY: build
build:
	@echo "Building $(SRC) -> $(OUT_BIN) [$(MODE)]"
	@mkdir -p $(OUT_DIR)
	$(ZIG) build-exe $(SRC) -O $(MODE) -femit-bin=$(OUT_BIN) -lc

.PHONY: run
run: build
	@echo "Running..."
	@$(OUT_BIN)

.PHONY: test
test:
	@echo "Running tests in zig.test..."
	$(ZIG) test $(ZIG_TEST)

.PHONY: clean
clean:
	@echo "Cleaning up..."
	@rm -rf $(OUT_DIR)

.PHONY: release
release:
	@echo "Building release (ReleaseFast)"
	@mkdir -p $(OUT_DIR)
	$(ZIG) build-exe $(SRC) -O ReleaseFast --target $(TARGET) -femit-bin=$(OUT_BIN)

.PHONY: help
help:
	@echo "Zig Makefile commands:"
	@echo "  make         - Build the project (default: Debug mode)"
	@echo "  make run     - Build and run the binary"
	@echo "  make clean   - Remove build artifacts"
	@echo "  make release - Build with ReleaseFast mode"
