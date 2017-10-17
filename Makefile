# Long Range Systems, LLC 2017

CC = $(CROSS_COMPILE)gcc
OUT = dbext.so
SOURCES = $(wildcard src/*.c)
OBJECTS = $(addprefix, $(DBEXT_BUILD_DIR), $(SOURCES:.c=.o))
LDFLAGS = -lb64 -luuid
CFLAGS = -Wall -fPIC

all: $(DBEXT_BUILD_DIR)/$(OUT)

$(DBEXT_BUILD_DIR)/$(OUT): $(OBJECTS)
	mkdir -p $(DBEXT_BUILD_DIR)
	$(CC) -shared -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) -o $@ $(CFLAGS) -c $<

install: $(DBEXT_BUILD_DIR)/$(OUT)
	mkdir -p $(PREFIX)/lib
	@echo Copying $(DBEXT_BUILD_DIR)/$(OUT) to $(PREFIX)/lib/
	cp $(DBEXT_BUILD_DIR)/$(OUT) $(PREFIX)/lib/

clean:
	rm -f $(DBEXT_BUILD_DIR)/$(OUT)
	rm -f src/*.o
