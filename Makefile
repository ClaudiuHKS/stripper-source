#(C)2004-2006 SourceMM Development Team
# Makefile written by David "BAILOPAN" Anderson

HL2SDK = ../../../sourcemm/hl2sdk
SMM_ROOT = ../../../sourcemm
SRCDS = ~/srcds
LIBPCRE = ../../../pcre-6.7

### EDIT BELOW FOR OTHER PROJECTS ###

OPT_FLAGS = -O3 -funroll-loops -s -pipe -fvisibility=hidden -fvisibility-inlines-hidden
GCC4_FLAGS = 
DEBUG_FLAGS = -g -ggdb3
CPP = gcc-4.1
BINARY = stripper_mm_i486.so

OBJECTS = stripper_mm.cpp parser.cpp concmds.cpp

LINK = vstdlib_i486.so tier0_i486.so -static-libgcc $(LIBPCRE)/.libs/libpcre.a

HL2PUB = $(HL2SDK)/public

INCLUDE = -I. -I.. -I$(HL2PUB) -I$(HL2PUB)/dlls -I$(HL2PUB)/engine -I$(HL2PUB)/tier0 -I$(HL2PUB)/tier1 \
	-I$(HL2PUB)/vstdlib -I$(HL2SDK)/tier1 -I$(SMM_ROOT) -I$(SMM_ROOT)/sourcehook -I$(SMM_ROOT)/sourcemm \
	-I$(LIBPCRE) -L$(LIBPCRE)/.libs

ifeq "$(DEBUG)" "true"
	BIN_DIR = Debug
	CFLAGS = $(DEBUG_FLAGS)
else
	BIN_DIR = Release
	CFLAGS = $(OPT_FLAGS)
endif

GCC_VERSION := $(shell $(CPP) -dumpversion >&1 | cut -b1)

CFLAGS += -D_LINUX -DNDEBUG -Dstricmp=strcasecmp -D_stricmp=strcasecmp -D_strnicmp=strncasecmp -Dstrnicmp=strncasecmp -D_snprintf=snprintf -D_vsnprintf=vsnprintf -D_alloca=alloca -Dstrcmpi=strcasecmp -Wall -Wno-non-virtual-dtor -Werror -fPIC -fno-exceptions -fno-rtti -msse

ifeq "$(GCC_VERSION)" "4"
	CFLAGS += $(GCC4_FLAGS)
endif

OBJ_LINUX := $(OBJECTS:%.cpp=$(BIN_DIR)/%.o)

$(BIN_DIR)/%.o: %.cpp
	$(CPP) $(INCLUDE) $(CFLAGS) -o $@ -c $<

all:
	mkdir -p $(BIN_DIR)
	ln -sf $(SRCDS)/bin/vstdlib_i486.so vstdlib_i486.so
	ln -sf $(SRCDS)/bin/tier0_i486.so tier0_i486.so
	$(MAKE) sourcemm
	rm -rf $(BINARY)
	ln -sf $(BIN_DIR)/$(BINARY) $(BINARY)

sourcemm: $(OBJ_LINUX)
	$(CPP) $(INCLUDE) $(CFLAGS) $(OBJ_LINUX) $(LINK) -shared -ldl -lm -o$(BIN_DIR)/$(BINARY)

debug:	
	$(MAKE) all DEBUG=true

default: all

clean:
	rm -rf Release/*.o
	rm -rf Release/$(BINARY)
	rm -rf Debug/*.o
	rm -rf Debug/$(BINARY)
