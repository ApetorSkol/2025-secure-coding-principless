#! /bin/sh
# Project: PV286 Secure Coding Makefile
# Author: Pospíšil Zbyněk (xpospi0k)
# Date: 2025-03-20

INCLUDE_DIRS = -I$(shell pwd)/libbtc/root/include -I/usr/local/include
LIB_DIRS     = -L$(shell pwd)/libbtc/root/lib -L/usr/local/lib
LIBS         = -lbtc

BINARY_NAME         = bip380
BINARY_PATH         = ./$(BINARY_NAME)
OUTPUT_FOLDER       = obj
SOURCE_FOLDER       = src/app

CC                  = g++
CFLAGS              = -std=c++17 -pedantic -Wall -Wextra -Werror -g -static
RM                  = rm -rf


rwildcard = $(foreach d,$(wildcard $(1)/*), \
             $(call rwildcard,$d,$2) \
             $(filter $(subst *,%,$2),$d))


# Gather all .cpp files from src/app (and its subfolders),
# then filter out main.cpp so we can compile them separately if needed.

APP_SOURCES_CPP = $(call rwildcard, $(SOURCE_FOLDER), *.cpp)
APP_SOURCES_C = $(call rwildcard, $(SOURCE_FOLDER), *.c)
APP_SOURCES_ALL = $(APP_SOURCES_CPP) $(APP_SOURCES_C)
# Exclude main.cpp from the normal object build, so we don't mix it with tests
APP_SOURCES_NOMAIN     = $(filter-out src/app/main.cpp, $(APP_SOURCES_ALL))

# Convert each .cpp in APP_SOURCES into an .o in obj folder
APP_OBJECTS     = $(patsubst src/app/%.cpp, obj/%.o, $(APP_SOURCES_NOMAIN))

# ---------------------------------------------------------
#  MAIN APP
# ---------------------------------------------------------
all: build

libbtc:
	git clone https://github.com/libbtc/libbtc.git
	cd libbtc ; ./autogen.sh
	mkdir -p libbtc/root
	cd libbtc ; ./configure --prefix=$(shell pwd)/libbtc/root
	cd libbtc ; make install

build: $(BINARY_PATH) libbtc

$(BINARY_PATH): $(APP_OBJECTS)
	@echo "LINKING -> $@"
	@mkdir -p $(@D)
	@$(CC) $(APP_OBJECTS) src/app/main.cpp -o $@ $(CFLAGS) $(INCLUDE_DIRS) $(LIB_DIRS) $(LIBS)

# For each .cpp (excluded main.cpp) compile to .o
obj/%.o: src/app/%.cpp
	@echo "COMPILING -> $<"
	@mkdir -p $(@D)
	@$(CC) -c $< -o $@ $(CFLAGS) $(INCLUDE_DIRS) $(LIB_DIRS) $(LIBS)

# ---------------------------------------------------------
#  TESTS
# ---------------------------------------------------------
# Build a separate test binary in obj_test/Tests
# This includes all .cpp in src/app except main.cpp (already excluded)
# plus all .cpp in src/tests.
# Then link against Google Test.

TEST_OUT_FOLDER     = obj_test
TEST_BINARY         = Tests
TEST_BINARY_PATH    = $(TEST_OUT_FOLDER)/$(TEST_BINARY)

# Gather all .cpp in src/tests
TEST_SOURCES        = $(call rwildcard, src/tests, *.cpp)
# Combine them with the app sources (which already exclude main.cpp)
ALL_TEST_SOURCES    = $(APP_SOURCES_NOMAIN) $(TEST_SOURCES)

TEST_CFLAGS         = -std=c++17 -pthread -g -Wall -Wextra
GTEST_LIBS          = -lgtest

# test: build test binary and then run it
test: test-build
	@echo "Running Google Tests..."
	./$(TEST_BINARY_PATH)

# Build only the test binary (don't run)
test-build:
	@echo "BUILDING TESTS -> $(TEST_BINARY_PATH)"
	@mkdir -p $(TEST_OUT_FOLDER)
	$(CC) $(TEST_CFLAGS) $(ALL_TEST_SOURCES) \
	    -I /usr/include \
	    -L /usr/lib/x86_64-linux-gnu \
	    $(GTEST_LIBS) \
	    -lbtc \
	    -o $(TEST_BINARY_PATH)

# Valgrind for dynamic analysis
valgrind: test-build
	@echo "Running tests with Valgrind..."
	valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all --error-exitcode=0 --log-file=valgrind_report.txt ./$(TEST_BINARY_PATH)

# Fuzzing
fuzz: fuzz_ArgParser fuzz_DeriveKey

fuzz_%: $(APP_OBJECTS)
	mkdir -p $(@D)
	clang++ -g -O1 -fsanitize=fuzzer,address $(APP_OBJECTS) src/fuzz/$@.cpp -o $@ $(INCLUDE_DIRS) $(LIB_DIRS) $(LIBS)

# ---------------------------------------------------------
#  OTHER TARGETS
# ---------------------------------------------------------
clean:
	$(RM) $(OUTPUT_FOLDER)
	$(RM) $(TEST_OUT_FOLDER)
	$(RM) $(BINARY_PATH)
	$(RM) bip380
	$(RM) packed.zip
	$(RM) fuzz_ArgParser
	$(RM) fuzz_DeriveKey

rel: clean build

zip: clean
	zip -r -9 $(BINARY_NAME).zip *
