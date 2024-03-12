module Main where

import HSApi.Coroutine

numbers = do
  yield 1
  yield 2
  yield 3
  Done

main = do
  if [1, 2, 3] == gen numbers
  then return ()
  else error "numbers mismatch"
