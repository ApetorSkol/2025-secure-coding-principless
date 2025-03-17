#!bin/sh
# Project: PV286, used also in other autor's projects
# Name: Makefile
# Author: Pospíšil Zbyněk (xpospi0k)
# Info: Makefile used for running the project.
#		Recursively goes through all subfolders it can find and compiles the project into executable file.
# Date: 2021-12-10

BINARY_NAME=bip380

OUTPUT_FOLDER=.
OBJECT_FOLDER=obj
SOURCE_FOLDER=src

CC=g++
CFLAGS=-std=c++17 -pedantic -Wall -Wextra -Werror -g
SUFFIX=cpp

ADDITIONAL_CLEANUP=docs
RM=rm -rf

BINARY_PATH=$(OUTPUT_FOLDER)/$(BINARY_NAME)

SRC_SUBFOLDERS=$(shell find $(SOURCE_FOLDER) -type d)
$(CC)=$(CC) $(foreach DIR, $(SRC_SUBFOLDERS),-I $(DIR))
vpath %.$(SUFFIX) $(SRC_SUBFOLDERS)
vpath %.h $(SRC_SUBFOLDERS)

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

SRC = $(call rwildcard,$(SOURCE_FOLDER),*.$(SUFFIX))
HDR = $(call rwildcard,$(SOURCE_FOLDER),*.h)
OBJ = $(patsubst $(SOURCE_FOLDER)/%.$(SUFFIX), $(OBJECT_FOLDER)/%.o, $(SRC))

$(BINARY_PATH) : $(OBJ)
	@echo LINKING
	@mkdir -p $(@D)
	@$(CC) $(OBJ) -o $@ $(CFLAGS)

$(OBJECT_FOLDER)/%.o: %.$(SUFFIX) $(HDR)
	@echo COMPILING $<
	@mkdir -p $(@D)
	@$(CC)  $< -c -o $@ $(CFLAGS)

.PHONY:  all build run clean zip docs
.SILENT: docs clean zip

all: docs build

docs: $(SRC) $(HDR)
	doxygen Doxyfile

build: $(BINARY_PATH)

clean:
	$(RM) $(OBJECT_FOLDER)
	$(RM) $(BINARY_PATH)
	$(RM) packed.zip
	$(RM) $(ADDITIONAL_CLEANUP)

rel: clean build

zip: clean
	zip -r -9 $(BINARY_NAME).zip *