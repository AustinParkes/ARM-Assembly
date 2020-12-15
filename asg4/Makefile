# Compiler flags
CFLAGS=-Wall -O0 -g -o

# Source file to do high level testing in
SRC=tstNode.c

# Compiler
CC=gcc

# Make executable for testing
xtst:$(SRC)
	$(CC) $(CFLAGS) $@ $^

clean:
	rm xtst
