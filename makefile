# HSApi
# /makefile
# This file is distributed under Mozilla Public License Version 2.0
# Copyright (c) 2024 Yao Zi. All rights reserved.

default: library

library:
	$(MAKE) -C HSApi

test:
	$(MAKE) -C tests

clean:
	$(MAKE) -C tests clean
	$(MAKE) -C HSApi clean
