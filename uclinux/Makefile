CC      = h8300-elf-gcc
OBJCOPY = h8300-elf-objcopy

#CFLAGS = -mh -mrelax -mint32
CFLAGS = -mh -mint32
CFLAGS += -static
#CFLAGS += -Wl,--entry=main -nostdlib
#CFLAGS += -nodefaultlibs
CFLAGS += -nostartfiles /usr/local/h8300-linux-uclibc/lib/crt0.o
#CFLAGS += -finhibit-size-directive -fno-ident -fomit-frame-pointer
CFLAGS += -I. 
CFLAGS += -I/usr/local/h8300-linux-uclibc/include
#CFLAGS += -Wall -v -save-temps

#LDFLAGS += -Wl,-T/usr/local/h8300-elf/lib/elf2flt.ld
LDFLAGS += -L/usr/local/h8300-linux-uclibc/lib# -lc -lgcc
#LDFLAGS += -Wl,-r		#-Ur for C++
LDFLAGS += -Wl,-elf2flt
#LDFLAGS += -Wl,-elf2flt-lc
LDFLAGS += -Wl,-move-rodata
#LDFLAGS += -Wl,--verbose #-Wl,-V

hello:	hello.c Makefile
	${CC} ${CFLAGS} -o $@ $@.c ${LDFLAGS}

tags:	hello.c
	etags *.c

clean:
	rm -f TAGS hello *~
