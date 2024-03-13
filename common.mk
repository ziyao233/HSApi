# HSApi
# /common.mk
# This file is distributed under Mozilla Public License Version 2.0
# Copyright (c) 2024 Yao Zi. All rights reserved.

GHCVER		?= 9.4.8
GHC		?= ghc-$(GHCVER)
GHCPKG		?= ghc-pkg-$(GHCVER)
CC		?= gcc
AR		?= ar

GHCFLAGS	?= -Werror -fforce-recomp
CFLAGS		?= -Wall -Wextra -pedantic -Werror -O2

%.o: %.hs
	$(GHC) $< -c $(GHCFLAGS)

%.o: %.c
	$(CC) $< -c $(CFLAGS) -o $@
