CC = gcc

NAME = RGFW
ODIN = odin
CUSTOM_CFLAGS =

LIBS := -w -ggdb

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
	LIB_EXT = _msvc.lib
endif
ifeq ($(detected_OS),Darwin)        # Mac OS X
	LIB_EXT = _osx.a
endif
ifeq ($(detected_OS),Linux)
	LIB_EXT = _linux.a
endif

all:
	make lib/$(NAME)$(LIB_EXT)

build-$(NAME):
	make lib/$(NAME)$(LIB_EXT)

debug:
ifeq ($(detected_OS),Windows)
	make clean
	.\build-libs.bat
	make lib/$(NAME)$(LIB_EXT)
else
	make clean
	make lib/$(NAME)$(LIB_EXT)
endif

source/$(NAME).o:
	$(CC) -I./source $(CUSTOM_CFLAGS) source/$(NAME).c -c $(LIBS) -fPIC -o source/$(NAME).o

lib/$(NAME)$(LIB_EXT): source/$(NAME).o
ifeq ($(detected_OS),Windows)
	.\build.bat
else
	mkdir -p lib
	$(AR) rcs $(NAME)$(LIB_EXT) source/$(NAME).o
	mv $(NAME)$(LIB_EXT) lib/
endif

clean:
	rm -f $(NAME).o source/$(NAME).o
	rm -r -f lib
	rm -f $(NAME).obj $(NAME).lib source/$(NAME).obj
