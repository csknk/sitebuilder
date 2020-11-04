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
ABS_PATH := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
HEADER_HTML := templates/header.html


#
CSS_HASH := $(shell sha256sum $(ASSETS_SOURCE_DIR)/style.css | head -c 10)
CSS_FILENAME := style-$(CSS_HASH).css
JS_HASH := $(shell sha256sum $(ASSETS_SOURCE_DIR)/index.js | head -c 10)
JS_FILENAME := ../assets/index-$(JS_HASH).js

# Main content build - TODO separate build for header/footer HTML so that unique filenames for JS/CSS
# files can be used to break browser caching. 
PANDOC_ARGS = -s \
	      -f markdown+autolink_bare_uris+task_lists \
	      --template templates/base.html \
	      -V 'mathfont:latinmodern-math.otf' -V 'monofont:DejaVuSansMono.ttf' --mathml \
	      --highlight-style breezeDark \
	      -A templates/footer.html \
	      -B templates/header.html \
	      -M js=$(JS_FILENAME)

.PHONY: all clean build_assets $(ASSET_FILES)

all: $(HEADER_HTML) $(TARGETS) $(ASSET_BUILDS) $(IMAGE_BUILDS)

$(HEADER_HTML): templates/header-source.html
	pandoc -M author="David Egan" -M title="Big Kahoona Burger!" -o $@ $<


$(ASSETS)/%: $(ASSETS_SOURCE_DIR)/%
	@mkdir -p $(ASSETS)
	$(eval FILE_HASH := $(shell sha256sum $^ | head -c 10))
	$(eval FILE_NAME := $(basename $@)-$(FILE_HASH)$(suffix $@))
	@echo "Copying $^"
	cp $^ $(FILE_NAME)
	scripts/compress.sh $(ABS_PATH)$(FILE_NAME)

$(IMAGES)/%: $(IMAGES_SOURCE_DIR)/%
	@mkdir -p $(IMAGES)
	@echo "Copying $^"
	cp $^ $@ 

# Pattern rule to build $(TARGETS)
$(BUILD)/%/index.html: $(MARKDOWN_SOURCE_DIR)/%.md $(HEADER_HTML)
	@mkdir -p $(@D)
	pandoc $(PANDOC_ARGS) --css ../assets/$(CSS_FILENAME) -o $@ $<

clean:
	rm -rf $(BUILD_DIRS)
