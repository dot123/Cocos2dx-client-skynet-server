CC = gcc
CFLAGS = -O2 -fPIC -Wall
LUADIR = /home/m/Desktop/talkbox-master/3rd/p/include
TARGET = p.so

.PHONY : all clean

all : $(TARGET)

$(TARGET) : lua-p.c
	$(CC) $(CFLAGS) -shared -o $@ -I../.. -I$(LUADIR) 

clean :
	rm -f $(TARGET)
