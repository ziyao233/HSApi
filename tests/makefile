# HSApi
# /tests/makefile
# This file is distributed under Mozilla Public License Version 2.0
# Copyright (c) 2024 Yao Zi. All rights reserved.

include ../common.mk

GHCFLAGS	+= -i../HSApi/hi
HSPKGS		:= transformers
GHCLDFLAGS	:= $(foreach lib,$(HSPKGS),-package $(lib))

default: testall

TESTS		:= \
coroutine.test file.test

TESTSEXEC	:= $(patsubst %.test, %.exec, $(TESTS))
TESTSOBJ	:= $(patsubst %.test, %.o, $(TESTS))
TESTSHI		:= $(patsubst %.test, %.hi, $(TESTS))

testall: $(TESTSOBJ) $(TESTSEXEC) $(TESTS)

clean:
	-rm -r $(TESTSEXEC) $(TESTSHI) $(TESTSOBJ)

%.o: %.hs
	@echo Compiling test $<
	@$(GHC) $< -c -o $@ $(GHCFLAGS)

%.test: %.exec
	@echo Running test $<
	@./$< >/dev/null

%.exec: %.o ../HSApi/libHSApi.a
	@echo Linking test $<
	@$(GHC) --make $< $(GHCFLAGS) ../HSApi/libHSApi.a -o $@ $(GHCLDFLAGS)
