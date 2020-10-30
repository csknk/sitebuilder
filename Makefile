MARKDOWN_SOURCE_DIR := src
ASSETS_SOURCE_DIR := assets
IMAGES_SOURCE_DIR := images

# Built directories
BUILD := build
ASSETS := $(BUILD)/$(ASSETS_SOURCE_DIR)
IMAGES := $(BUILD)/$(IMAGES_SOURCE_DIR)

# Base names of all markdown files in $(MARKDOWN_SOURCE_DIR) 
MARKDOWN_FILES := $(notdir $(wildcard $(MARKDOWN_SOURCE_DIR)/*.md))
# Asset files (JS, CSS)
ASSET_FILES := $(notdir $(wildcard $(ASSETS_SOURCE_DIR)/*))
# Images
IMAGE_FILES := $(notdir $(wildcard $(IMAGES_SOURCE_DIR)/*))

# Directories to be built
BUILD_DIRS := $(BUILD) $(ASSETS) $(IMAGES)

# Pattern substitution to create the build targets.
# Do this so we can run all: $(TARGETS)
TARGETS :=$(MARKDOWN_FILES:%.md=$(BUILD)/%/index.html)
ASSET_BUILDS :=$(ASSET_FILES:%=$(ASSETS)/%)
IMAGE_BUILDS :=$(IMAGE_FILES:%=$(IMAGES)/%)
$(info $(IMAGE_BUILDS))

PANDOC_ARGS = -s \
	      -f markdown+autolink_bare_uris+task_lists \
	      --template templates/base.html \
	      -V 'mathfont:latinmodern-math.otf' -V 'monofont:DejaVuSansMono.ttf' --mathml \
	      --highlight-style breezeDark \
	      --css ../assets/compressed-style.css \
	      -A templates/footer.html

CSS_HASH := $(shell sha256sum $(ASSETS_SOURCE_DIR)/compressed-style.css | head -c 10)
CSS_FILENAME := $(ASSETS_SOURCE_DIR)/compressed-style$(CSS_HASH).css))

.PHONY: all clean build_assets $(ASSET_FILES)

all: $(TARGETS) $(ASSET_BUILDS) $(IMAGE_BUILDS)

$(ASSETS)/%: $(ASSETS_SOURCE_DIR)/%
	@mkdir -p $(ASSETS)
	@echo "Copying $^"
	cp $^ $@ 

$(IMAGES)/%: $(IMAGES_SOURCE_DIR)/%
	@mkdir -p $(IMAGES)
	@echo "Copying $^"
	cp $^ $@ 

# Pattern rule to build $(TARGETS)
$(BUILD)/%/index.html: $(MARKDOWN_SOURCE_DIR)/%.md 
	@mkdir -p $(@D)
	pandoc $(PANDOC_ARGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIRS)
