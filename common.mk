# HSApi
# /common.mk
# This file is distributed under Mozilla Public License Version 2.0
# Copyright (c) 2024 Yao Zi. All rights reserved.

GHC		?= ghc-9.4.8
CC		?= gcc
AR		?= ar

GHCFLAGS	?= -Werror
CFLAGS		?= -Wall -Wextra -pedantic -Werror -O2

%.o: %.hs
	$(GHC) $< -c $(GHCFLAGS) -hidir $(HIDIR)
