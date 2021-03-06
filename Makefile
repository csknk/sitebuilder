MARKDOWN_SOURCE_DIR := src
ASSETS_SOURCE_DIR := assets
IMAGES_SOURCE_DIR := images
CONFIG := data/config.yaml
NAV := data/nav.yaml

# Directories built by make
BUILD := build
ASSETS := $(BUILD)/$(ASSETS_SOURCE_DIR)
IMAGES := $(BUILD)/$(IMAGES_SOURCE_DIR)

# Base names of all markdown files in $(MARKDOWN_SOURCE_DIR), same for assets (js & css) & images 
MARKDOWN_FILES := $(notdir $(wildcard $(MARKDOWN_SOURCE_DIR)/*.md))
ASSET_FILES := $(notdir $(wildcard $(ASSETS_SOURCE_DIR)/*))
IMAGE_FILES := $(notdir $(wildcard $(IMAGES_SOURCE_DIR)/*))

# Directories to be built
BUILD_DIRS := $(BUILD) $(ASSETS) $(IMAGES)

# Pattern substitution to create the build targets. Do this so we can run all: $(TARGETS) etc
TARGETS :=$(MARKDOWN_FILES:%.md=$(BUILD)/%/index.html)
ASSET_BUILDS :=$(ASSET_FILES:%=$(ASSETS)/%)
IMAGE_BUILDS :=$(IMAGE_FILES:%=$(IMAGES)/%)
ABS_PATH := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
LINKS :=$(basename $(MARKDOWN_FILES))
HEADER_HTML := templates/header.html

# The hash is needed in a Make variable to build the link to the file created in the $(ASSETS) recipe.
CSS_HASH := $(shell sha256sum $(ASSETS_SOURCE_DIR)/style.css | head -c 10)
CSS_FILENAME := ../assets/style-$(CSS_HASH).css
JS_HASH := $(shell sha256sum $(ASSETS_SOURCE_DIR)/index.js | head -c 10)
JS_FILENAME := ../assets/index-$(JS_HASH).js

# Main content pandoc build arguments 
# Setting `-f markdown+autolink_bare_uris` causes a problem when building links in Pandoc templates.
PANDOC_ARGS = -s \
	      -f markdown+task_lists \
	      --template templates/base.html \
	      -V 'mathfont:latinmodern-math.otf' -V 'monofont:DejaVuSansMono.ttf' --mathml \
	      --highlight-style breezeDark \
	      -A templates/footer.html \
	      -B $(HEADER_HTML) \
	      --css $(CSS_FILENAME) \
	      -M js=$(JS_FILENAME) \
	      --metadata-file $(CONFIG) \
	      --metadata-file $(NAV) \

SHELL := /bin/bash

.PHONY: all clean build_assets $(ASSET_FILES) clear_nav

all: $(LINKS) $(TARGETS) $(ASSET_BUILDS) $(IMAGE_BUILDS)
#all: $(TARGETS) $(ASSET_BUILDS) $(IMAGE_BUILDS)

# The source markdown is really just HTML - use this hack so that pandoc inserts the required variables
# during the build.
$(HEADER_HTML): templates/header-source.md
	pandoc \
		--metadata-file $(CONFIG) \
		--template templates/header-source.html \
		-o $@ $<

$(ASSETS)/%: $(ASSETS_SOURCE_DIR)/%
	@mkdir -p $(ASSETS)
	$(eval FILE_HASH := $(shell sha256sum $^ | head -c 10))
	$(eval FILE_NAME := $(basename $@)-$(FILE_HASH)$(suffix $@))
	@echo "Copying $^"
	@cp $^ $(FILE_NAME)
	@scripts/compress.sh $(ABS_PATH)$(FILE_NAME)

$(IMAGES)/%: $(IMAGES_SOURCE_DIR)/%
	@mkdir -p $(IMAGES)
	@echo "Copying $^"
	@cp $^ $@ 

# Pattern rule to make links to $(TARGETS).
%: $(MARKDOWN_SOURCE_DIR)/%.md | clear_nav
	@[ -f $(NAV) ] || echo "links:" > $(NAV)
	@if [ $@ != README ]; then \
		echo -e "  -\n    url: /$@\n    name: \
		$$(scripts/parse_yaml.py $^ title)" >> $(NAV); fi

clear_nav:
	@echo "Clearing $(NAV)"
	@if [ -f $(NAV) ]; then rm $(NAV); else echo "No nav file to delete..."; fi

#[ -z $${date} ] && date=$$(date -u '+%B %d, %Y') \
# Pattern rule to build $(TARGETS). If the file is README.md, make it the homepage (build/index.html)
$(BUILD)/%/index.html: $(MARKDOWN_SOURCE_DIR)/%.md | $(HEADER_HTML) 
	@mkdir -p $(@D)
	@# If the source file has no date set, set it
	@scripts/set_date.py $<
	@if [ $(basename $<) = src/README ]; then \
		pandoc $(PANDOC_ARGS) -o $(BUILD)/index.html $< ; \
		else pandoc $(PANDOC_ARGS) -o $@ $< ; fi

clean:
	rm -rf $(BUILD_DIRS)
	@[ -f $(NAV) ] && rm $(NAV)
