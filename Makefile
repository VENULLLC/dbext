# Long Range Systems, LLC 2017

CC = $(CROSS_COMPILE)gcc
OUT = dbext.so
SOURCES = $(wildcard src/*.c)
OBJECTS = $(notdir $(SOURCES:.c=.o))
LDFLAGS = -Wl,-rpath,'$$ORIGIN' -fPIC -lb64 -luuid
CFLAGS = -Wall -fPIC

all: $(DBEXT_BUILD_DIR)/$(OUT)

$(DBEXT_BUILD_DIR)/$(OUT): $(addprefix $(DBEXT_BUILD_DIR)/, $(OBJECTS))
	mkdir -p $(DBEXT_BUILD_DIR)
	@echo $^
	$(CC) -shared -o $@ $^ $(LDFLAGS)

%.o: $(SOURCES)
	mkdir -p $(DBEXT_BUILD_DIR)
	$(CC) -o $@ $(CFLAGS) -c $<

install: $(DBEXT_BUILD_DIR)/$(OUT)
	mkdir -p $(PREFIX)/lib
	@echo Copying $(DBEXT_BUILD_DIR)/$(OUT) to $(PREFIX)/lib/
	cp $(DBEXT_BUILD_DIR)/$(OUT) $(PREFIX)/lib/

clean:
	rm -f $(DBEXT_BUILD_DIR)/$(OUT)
	rm -f src/*.o
