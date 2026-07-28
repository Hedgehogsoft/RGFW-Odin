CC = gcc

ODIN = odin
CUSTOM_CFLAGS =

LIBS := -w -lgdi32 -lm -lopengl32 -lwinmm -ggdb
LIB_EXT = .lib

ifneq (,$(filter $(CC),winegcc x86_64-w64-mingw32-gcc))
    detected_OS := Windows
	LIB_EXT = .lib
else
	ifeq '$(findstring ;,$(PATH))' ';'
		detected_OS := Windows
	else
		detected_OS := $(shell uname 2>/dev/null || echo Unknown)
		detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
		detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
		detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
	endif
endif

ifeq ($(detected_OS),Windows)
	LIBS := -ggdb -lshell32 -lgdi32 -lopengl32 -lwinmm
	LIB_EXT = .dll
endif
ifeq ($(detected_OS),Darwin)        # Mac OS X
	LIBS := -lm -framework Foundation -framework AppKit -framework OpenGL -framework CoreVideo -w
	LIB_EXT = .a
endif
ifeq ($(detected_OS),Linux)
    LIBS := -lXrandr -lX11 -lm -lGL
	LIB_EXT = .a
endif


all:
	make lib/RGFW$(LIB_EXT)
	$(ODIN) run examples/basic/basic.odin -file
	$(ODIN) run examples/basic-buffer/basic-buffer.odin -file
	$(ODIN) run examples/clipboard/clipboard.odin -file

build-RGFW:
	make lib/RGFW$(LIB_EXT)

debug:
ifeq ($(detected_OS),Windows)
	make clean
	.\build-libs.bat
	make lib/RGFW$(LIB_EXT)
	$(ODIN) run examples/basic/basic.odin -file
	$(ODIN) run examples/basic-buffer/basic-buffer.odin -file
	$(ODIN) run examples/clipboard/clipboard.odin -file
else
	make clean
	make lib/RGFW$(LIB_EXT)
	$(ODIN) run examples/basic/basic.odin -file
	$(ODIN) run examples/basic-buffer/basic-buffer.odin -file
	$(ODIN) run examples/clipboard/clipboard.odin -file
endif

source/RGFW.o:
	$(CC) -I./source/RGFW -I./source $(CUSTOM_CFLAGS) source/RGFW.c -c $(LIBS) -fPIC -o source/RGFW.o

lib/RGFW$(LIB_EXT):
	mkdir -p lib
ifeq ($(detected_OS),Windows)
	.\build-libs.bat
else
	make source/RGFW.o
	$(AR) rcs RGFW.a source/RGFW.o
	mv RGFW.a lib/RGFW.a
endif

clean:
	rm -f source/RGFW.o
	rm -r -f lib
	rm -f RGFW.lib source/RGFW.obj
