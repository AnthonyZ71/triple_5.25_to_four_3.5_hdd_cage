# --------------------------------------------------------------------------------------------------------------------
#
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
# or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
#
# --------------------------------------------------------------------------------------------------------------------
#
# This makefile expects an OpenSCAD file named $(PREFIX).scad that defines
# the following variables:
#
# PART    -- the name of a part to generate
# VERBOSE -- logically true if you want verbose output (optional)
#
# The OpenSCAD program should have logic that renders a single part by name:
#
# if (PART == "foo") {
#     foo();
# } else if (PART == "bar") {
#     bar();
# } else if (PART == "foo-bar") {
#     foo_bar();
# }
#
# This makefile will use OpenSCAD to create individual model (STL) files and
# image (PNG) files for each declared part
#
# So if PREFIX=widget, then the created files will be:
#
# stl/widget-foo.stl stl/widget-bar.stl stl/widget-foo-bar.stl
# png/widget-foo.png png/widget-bar.png png/widget-foo-bar.png

CPUS ?= $(shell nproc)
MAKEFLAGS += --jobs=$(CPUS)
PREFIX=cage

# ----- Local OpenSCAD settings -----------------------------------------------

# OpenSCAD binary and options
OPENSCAD=openscad
OPENSCAD_OPTIONS=-DVERBOSE=false
IMAGE_OPTIONS=--imgsize=1024,768 --colorscheme=Solarized

SLICER=prusaslicer
SLICER_OPTIONS=--printer-technology FFF --center 100,100 -g --loglevel 0

# ----- Everything after this should not need modification --------------------

check_defined = $(strip $(foreach 1,$1, $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = $(if $(value $1),, $(error Undefined $1$(if $2, ($2))$(if $(value @), required by target `$@')))

# Scripts
EXPAND=scad-expand.py
DEPEND=scad-dependencies.py

# Names of parts to build
PARTS=$(shell grep 'PART == ' $(PREFIX).scad | cut -d'"' -f2)
SOURCES=$(shell $(DEPEND) $(PREFIX).scad)

STL=stl
IMAGE=png
GCODE=gcode

MODELS=$(patsubst %,$(STL)/$(PREFIX)-%.$(STL),$(PARTS))
IMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)-%.$(IMAGE),$(PARTS))
GCODES=$(patsubst %,$(GCODE)/$(PREFIX)-%.$(GCODE),$(PARTS))
ALLIN1=$(PREFIX)-all.scad

FAN_COVERS=crosshair crosshex grid none teardrop
SHROUD_MODELS=$(patsubst %,$(STL)/$(PREFIX)-fan_shroud-%.$(STL),$(FAN_COVERS))
SHROUD_IMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)-fan_shroud-%.$(IMAGE),$(FAN_COVERS))


all:	models images gcodes shroud_models shroud_images $(ALLIN1)

directories:
	mkdir -p $(STL) $(IMAGE) $(GCODE)

models: directories $(MODELS)

images: directories $(IMAGES)

gcodes: directories $(GCODES)

shroud_models: directories $(SHROUD_MODELS) 

shroud_images: directories $(SHROUD_IMAGES) 

clean:
	rm -f $(STL)/$(PREFIX)-* $(IMAGE)/$(PREFIX)-* $(GCODE)/$(PREFIX)-* $(ALLIN1)

cleanall:
	rm -rf $(STL) $(IMAGE) $(GCODE) $(ALLIN1)

$(SHROUD_MODELS) : $(STL)/$(PREFIX)-fan_shroud-%.$(STL) : $(SOURCES)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"fan_shroud\" -Dgrill_style=\"$(subst $(PREFIX)-fan_shroud-,fan_cover_,$(subst .$(STL),.$(STL),$(@F)))\" $<

$(SHROUD_IMAGES) : $(IMAGE)/$(PREFIX)-fan_shroud-%.$(IMAGE) : $(SOURCES)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"fan_shroud\" -Dgrill_style=\"$(subst $(PREFIX)-fan_shroud-,fan_cover_,$(subst .$(IMAGE),.$(STL),$(@F)))\" $(IMAGE_OPTIONS) $<

# Dependencies for models

$(MODELS) : $(STL)/$(PREFIX)-%.$(STL) : $(SOURCES)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(STL),,$(@F)))\" $<

# Dependencies for images

$(IMAGES) : $(IMAGE)/$(PREFIX)-%.$(IMAGE) : $(SOURCES)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(IMAGE),,$(@F)))\" $(IMAGE_OPTIONS) $<

# Dependencies for gcodes

$(GCODES) : $(GCODE)/$(PREFIX)-%.$(GCODE) : $(STL)/$(PREFIX)-%.$(STL) slicer-%.ini
	$(SLICER) $(SLICER_OPTIONS) --load slicer-$(subst $(PREFIX)-,,$(subst .$(GCODE),,$(@F))).ini -o $@ $<

# Dependencies for all-in-1
$(ALLIN1) : $(SOURCES)
	$(EXPAND) $(PREFIX).scad $(ALLIN1)


