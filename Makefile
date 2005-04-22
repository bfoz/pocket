TARGET   = pocket

SRCS        = main.cc pocket.cc intelhex.cc kitsrus.cc chipinfo.cc

LN = ln -s
MV = mv
RM = -rm -rf
CC = g++

INCDIRS += -I/usr/local/include -I/usr/include/gcc/darwin/3.3/c++
#INCDIRS += -I/usr/local/include -I/usr/include/gcc/darwin/3.3/c++
LIBDIRS += -L/usr/local/lib

LDFLAGS += -lstdc++ $(LIBDIRS)
CFLAGS = -O -finline-functions $(INCDIRS)

OBJS =	$(SRCS:S/.cc$/.o/:S/.c$/.o/)

default: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(SRCS) $(CFLAGS) $(LDFLAGS) -lm

clean:
	$(RM) $(OBJS)
	$(RM) $(TARGET)

test: intelhex.o test_intelhex.o
	$(CC) -o $(.TARGET) $(.ALLSRC) $(CFLAGS) $(LDFLAGS) -lm
