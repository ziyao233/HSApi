# HSApi
# /HSApi/makefile
# This file is distributed under Mozilla Public License Version 2.0
# Copyright (c) 2024 Yao Zi. All rights reserved.

include ../common.mk

OBJS		:= Coroutine.o

HIDIR		?= hi
LIB		:= libHSApi.a

default: $(LIB)

$(LIB): $(OBJS)
	$(AR) rc $(LIB) $(OBJS)

%.o: %.hs
	$(GHC) $< -c $(GHCFLAGS) -hidir $(HIDIR)

clean:
	-rm -r $(OBJS)

disbuild: clean
	-rm -r $(LIB)
	-rm -rf $(HIDIR)
