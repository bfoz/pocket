TARGET   = pocket

SRCS        = main.cc pocket.cc tty.cc intelhex.cc

LN = ln -s
MV = mv
RM = -rm -rf
CC = gcc

INCDIRS += -I/usr/local/include
LIBDIRS += -L/usr/local/lib

LDFLAGS += -lstdc++ $(LIBDIRS)
CFLAGS = -O -finline-functions $(INCDIRS)

OBJS =	$(SRCS:S/.cc$/.o/:S/.c$/.o/)

default: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $(.TARGET) $(.ALLSRC) $(CFLAGS) $(LDFLAGS) -lm

clean:
	$(RM) $(OBJS)

test: intelhex.o test_intelhex.o
	$(CC) -o $(.TARGET) $(.ALLSRC) $(CFLAGS) $(LDFLAGS) -lm