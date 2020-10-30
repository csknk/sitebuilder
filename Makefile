SRC := src
BUILD := build
ASSET_SOURCES := assets
ASSETS := $(BUILD)/$(ASSET_SOURCES)

# Base names of all markdown files in $(SRC) 
SRCS := $(notdir $(wildcard $(SRC)/*.md))

# Asset files (JS, CSS)
ASSET_FILES := $(notdir $(wildcard $(ASSET_SOURCES)/*))

# Directories to be built
BUILD_DIRS := $(BUILD) $(ASSETS)

# Pattern substitution to create the build targets.
# Do this so we can run all: $(TARGETS)
TARGETS :=$(SRCS:%.md=$(BUILD)/%/index.html)
ASSET_BUILDS :=$(ASSET_FILES:%=$(ASSETS)/%)
$(info ASSET_BUILDS = $(ASSET_BUILDS))
$(info TARGETS = $(TARGETS))

PANDOC_ARGS = -s \
	      -f markdown+autolink_bare_uris+task_lists \
	      --template templates/base.html \
	      -V 'mathfont:latinmodern-math.otf' -V 'monofont:DejaVuSansMono.ttf' --mathml \
	      --highlight-style breezeDark \
	      --css ../assets/compressed-style.css \
	      -A templates/footer.html

CSS_HASH := $(shell sha256sum $(ASSET_SOURCES)/compressed-style.css | head -c 10)
CSS_FILENAME := $(ASSET_SOURCES)/compressed-style$(CSS_HASH).css))

#$(info CSS_FILENAME = $(CSS_FILENAME))

.PHONY: all clean build_assets $(ASSET_FILES)

all: $(TARGETS) $(ASSET_BUILDS)

$(ASSETS)/%: $(ASSET_SOURCES)/%
	@mkdir -p $(ASSETS)
	@echo "Copying $^"
	cp $^ $@ 

# Pattern rule to build $(TARGETS)
$(BUILD)/%/index.html: $(SRC)/%.md 
	@mkdir -p $(@D)
	pandoc $(PANDOC_ARGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIRS)
# @TODO tidy up references

#build_assets: $(BUILD)
#	@mkdir -p $^/assets
#	# Foreach file in assets, give a unique name and move to build/assets
#	
#	ID=$$(sha256sum assets/compressed-style.css | head -c 10)
#	cp assets/compressed-style.css $^/assets/$(ID)

