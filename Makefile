PREFIX ?= /usr/local
MANDIR ?= $(PREFIX)/share/man/man1/
BUILDTYPE ?= Release
SHELL = /bin/bash

# inherit from env if set
CC := $(CC)
CXX := $(CXX)
CFLAGS := $(CFLAGS)
CXXFLAGS := $(CXXFLAGS) -std=c++11
LDFLAGS := $(LDFLAGS)
WARNING_FLAGS := -Wall -Wshadow -Wsign-compare -Wextra -Wunreachable-code -Wuninitialized -Wshadow
RELEASE_FLAGS := -O3 -DNDEBUG
DEBUG_FLAGS := -O0 -DDEBUG -fno-inline-functions -fno-omit-frame-pointer

ifeq ($(BUILDTYPE),Release)
	FINAL_FLAGS := -g $(WARNING_FLAGS) $(RELEASE_FLAGS)
else
	FINAL_FLAGS := -g $(WARNING_FLAGS) $(DEBUG_FLAGS)
endif

all: tippecanoe tippecanoe-enumerate tippecanoe-decode tile-join unit tippecanoe-json-tool

docs: man/tippecanoe.1

install: tippecanoe tippecanoe-enumerate tippecanoe-decode tile-join tippecanoe-json-tool
	mkdir -p $(PREFIX)/bin
	mkdir -p $(MANDIR)
	cp tippecanoe $(PREFIX)/bin/tippecanoe
	cp tippecanoe-enumerate $(PREFIX)/bin/tippecanoe-enumerate
	cp tippecanoe-decode $(PREFIX)/bin/tippecanoe-decode
	cp tippecanoe-json-tool $(PREFIX)/bin/tippecanoe-json-tool
	cp tile-join $(PREFIX)/bin/tile-join
	cp man/tippecanoe.1 $(MANDIR)/tippecanoe.1

uninstall:
	rm $(PREFIX)/bin/tippecanoe $(PREFIX)/bin/tippecanoe-enumerate $(PREFIX)/bin/tippecanoe-decode $(PREFIX)/bin/tile-join $(MANDIR)/tippecanoe.1 $(PREFIX)/bin/tippecanoe-json-tool

man/tippecanoe.1: README.md
	md2man-roff README.md > man/tippecanoe.1

PG=

H = $(wildcard *.h) $(wildcard *.hpp)
C = $(wildcard *.c) $(wildcard *.cpp)

INCLUDES = -I/usr/local/include -I.
LIBS = -L/usr/local/lib

tippecanoe: geojson.o jsonpull/jsonpull.o tile.o pool.o mbtiles.o geometry.o projection.o memfile.o mvt.o serial.o main.o text.o dirtiles.o plugin.o read_json.o write_json.o geobuf.o evaluator.o geocsv.o csv.o geojson-loop.o
	$(CXX) $(PG) $(LIBS) $(FINAL_FLAGS) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) -lm -lz -lsqlite3 -lpthread

tippecanoe-enumerate: enumerate.o
	$(CXX) $(PG) $(LIBS) $(FINAL_FLAGS) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) -lsqlite3

tippecanoe-decode: decode.o projection.o mvt.o write_json.o text.o jsonpull/jsonpull.o dirtiles.o
	$(CXX) $(PG) $(LIBS) $(FINAL_FLAGS) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) -lm -lz -lsqlite3

tile-join: tile-join.o projection.o pool.o mbtiles.o mvt.o memfile.o dirtiles.o jsonpull/jsonpull.o text.o evaluator.o csv.o write_json.o
	$(CXX) $(PG) $(LIBS) $(FINAL_FLAGS) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) -lm -lz -lsqlite3 -lpthread

tippecanoe-json-tool: jsontool.o jsonpull/jsonpull.o csv.o text.o geojson-loop.o
	$(CXX) $(PG) $(LIBS) $(FINAL_FLAGS) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) -lm -lz -lsqlite3 -lpthread

unit: unit.o text.o
	$(CXX) $(PG) $(LIBS) $(FINAL_FLAGS) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) -lm -lz -lsqlite3 -lpthread

-include $(wildcard *.d)

%.o: %.c
	$(CC) -MMD $(PG) $(INCLUDES) $(FINAL_FLAGS) $(CFLAGS) -c -o $@ $<

%.o: %.cpp
	$(CXX) -MMD $(PG) $(INCLUDES) $(FINAL_FLAGS) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f ./tippecanoe ./tippecanoe-* ./tile-join ./unit *.o *.d */*.o */*.d

indent:
	clang-format -i -style="{BasedOnStyle: Google, IndentWidth: 8, UseTab: Always, AllowShortIfStatementsOnASingleLine: false, ColumnLimit: 0, ContinuationIndentWidth: 8, SpaceAfterCStyleCast: true, IndentCaseLabels: false, AllowShortBlocksOnASingleLine: false, AllowShortFunctionsOnASingleLine: false, SortIncludes: false}" $(C) $(H)
