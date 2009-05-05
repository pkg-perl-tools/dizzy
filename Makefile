LDFLAGS ?= -lGL -lglut -lm -lrt
CFLAGS  ?= -Wall -Wextra -Os -g -std=gnu99

OBJFILES = main.o textures.o render.o

all: dizzy

textures_data.h: %.h: textures/* textures/
	./maketextures

textures.o: textures_data.h

dizzy: textures_data.h $(OBJFILES)
	$(CC) $(LDFLAGS) $(OBJFILES) -o $@

clean:
	$(RM) dizzy textures_data.h $(OBJFILES)
