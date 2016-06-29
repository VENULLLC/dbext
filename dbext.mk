# src/dbext.mk
# Copyright (C) 2016 Long Range Systems, LLC.  All rights reserved.
# Top-level makefile include to build SQLite extension module

ifndef DBEXT_SRC_DIR
  DBEXT_SRC_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
endif

DBEXT_MK := $(lastword $(MAKEFILE_LIST))

ifndef PREFIX
  ${error PREFIX is not defined!}
endif

DBEXT_BUILD_DIR = $(if $(TARGET_TUPLE),$(DBEXT_SRC_DIR)/build-$(TARGET_TUPLE),$(DBEXT_SRC_DIR)/build-native)

DBEXT_SO = $(PREFIX)/lib/dbext.so

define rm-dbext-lib
rm -f $(PREFIX)/lib/dbext.so* $(PREFIX)/lib/dbext.a $(PREFIX)/lib/dbext.la
endef

DBEXT_CONFIGURE = $(DBEXT_SRC_DIR)/configure

.PRECIOUS: $(DBEXT_CONFIGURE) $(DBEXT_SRC_DIR)/Makefile.in
$(DBEXT_CONFIGURE) $(DBEXT_SRC_DIR)/Makefile.in: $(DBEXT_SRC_DIR)/configure.ac $(DBEXT_SRC_DIR)/Makefile.am $(DBEXT_SRC_DIR)/bootstrap $(DBEXT_MK) 
	$(call rm-dbext-lib) 
	cd "$(DBEXT_SRC_DIR)" && ./bootstrap
	touch -c "$(DBEXT_SRC_DIR)/configure"


DBEXT_BUILD_MAKEFILE = $(DBEXT_BUILD_DIR)/Makefile
.PRECIOUS: $(DBEXT_BUILD_MAKEFILE)
$(DBEXT_BUILD_MAKEFILE): $(DBEXT_CONFIGURE) $(DBEXT_SRC_DIR)/Makefile.in $($(CROSS_TOOLCHAIN_DEPS) $(DBEXT_MK) $(LIBB64_DEPS) $(LIBUUID_DEPS)
	echo DBEXT_DEPS = $^
	$(call rm-dbext-lib) 
	mkdir -p $(dir $@)
	cd $(dir $@) && $(DBEXT_CONFIGURE) $(if $(BUILD_TUPLE),--build=$(BUILD_TUPLE)) $(if $(TARGET_TUPLE),--host=$(TARGET_TUPLE)) $(if $(PREFIX),--prefix=$(PREFIX)) CPPFLAGS="$(if $(PREFIX),-I$(PREFIX)/include) $(if $(SQLITE_INCLUDE_DIR),-I$(SQLITE_INCLUDE_DIR))" $(if $(PREFIX),LDFLAGS=-L$(PREFIX)/lib)


.PHONY: $(DBEXT_SO)
$(DBEXT_SO): $(DBEXT_BUILD_DIR)/Makefile 
	$(call rm-dbext-lib) 
	$(MAKE) -C $(dir $(filter %/Makefile,$^)) install



