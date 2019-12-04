# Long Range Systems, LLC 2017

DBEXT_BUILD_DIR ?= $(PWD)/build
DBEXT_DEPS_DIR ?= $(PWD)/deps
PREFIX ?= $(DBEXT_BUILD_DIR)
CC = $(CROSS_COMPILE)gcc
OUT = dbext.so
SOURCES = $(wildcard src/*.c)
OBJECTS = $(notdir $(SOURCES:.c=.o))
FINAL_OBJECTS = $(addprefix $(DBEXT_BUILD_DIR)/, $(OBJECTS))
LDFLAGS = -Wl,-rpath,'$$ORIGIN' -L$(DBEXT_DEPS_DIR)/libb64-1.2/src -L$(DBEXT_BUILD_DIR)/uuid/lib -lb64 -luuid
CFLAGS = -Wall -I$(DBEXT_DEPS_DIR)/libb64-1.2/include -I$(DBEXT_BUILD_DIR)/uuid/include -fPIC

all: $(PREFIX)/$(OUT)

libb64-1.2.src.zip:
	wget https://sourceforge.net/projects/libb64/files/libb64/libb64/libb64-1.2.src.zip
	touch $@

deps/libb64-1.2/src/libb64.a: libb64-1.2.src.zip
	mkdir -p deps
	cd deps && unzip -o ../libb64-1.2.src.zip
	cd deps/libb64-1.2 && $(MAKE)
	
libuuid-1.0.3.tar.gz:
	wget http://sourceforge.net/projects/libuuid/files/libuuid-1.0.3.tar.gz
	touch $@

$(DBEXT_BUILD_DIR)/uuid/lib/libuuid.a: libuuid-1.0.3.tar.gz
	mkdir -p deps
	cd deps && tar xf ../libuuid-1.0.3.tar.gz
	cd deps/libuuid-1.0.3 && ./configure --with-pic --disable-shared --enable-static --prefix=$(DBEXT_BUILD_DIR)/uuid --host=$(if $(TARGET_TUPLE),$(TARGET_TUPLE),$(shell gcc -dumpmachine)) && CFLAGS=-fPIC $(MAKE) && $(MAKE) install

$(PREFIX)/$(OUT): deps/libb64-1.2/src/libb64.a $(DBEXT_BUILD_DIR)/uuid/lib/libuuid.a $(FINAL_OBJECTS)
	@echo $(SOURCES)
	mkdir -p $(DBEXT_BUILD_DIR)
	mkdir -p $(PREFIX)
	@echo $^
	$(CC) -shared -o $@ $(FINAL_OBJECTS) $(LDFLAGS)

$(DBEXT_BUILD_DIR)/tracker_dbext.o: src/tracker_dbext.c deps/libb64-1.2/src/libb64.a $(DBEXT_BUILD_DIR)/uuid/lib/libuuid.a
	mkdir -p $(DBEXT_BUILD_DIR)
	$(CC) -o $@ $(CFLAGS) -c src/tracker_dbext.c

install: $(DBEXT_BUILD_DIR)/$(OUT)
	mkdir -p $(PREFIX)/lib
	@echo Copying $(DBEXT_BUILD_DIR)/$(OUT) to $(PREFIX)/lib/
	cp $(DBEXT_BUILD_DIR)/$(OUT) $(PREFIX)/lib/

clean:
	rm -rf $(DBEXT_BUILD_DIR)/uuid
	rm -f $(DBEXT_BUILD_DIR)/$(OUT)
	rm -f $(DBEXT_BUILD_DIR)/*.o
	rm -f src/*.o
	$(MAKE) -C deps/libb64-1.2 clean
	$(MAKE) -C deps/libuuid-1.0.3 distclean

.PHONY: clean
