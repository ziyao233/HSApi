-- HSApi.Coroutine
-- /HSApi/Coroutine.hs
-- This file is distributed under Mozilla Public License Version 2.0
-- Copyright (c) 2024 Yao Zi. All rights reserved.

module HSApi.Coroutine where

import Control.Monad

data SusVal req rep a = SusVal req (rep -> a)

instance Functor (SusVal req rep) where
  fmap f (SusVal req g) = SusVal req (f . g)

data Co s a = Run a | Done | Yield (s (Co s a))

instance Functor s => Monad (Co s) where
  return = pure
  Run x >>= f = f x
  Yield s >>= f = Yield $ fmap (>>= f) s
  Done >>= _ = error "Binding applied to Done"

instance Functor s => Functor (Co s) where
  fmap = liftM

instance Functor s => Applicative (Co s) where
  pure  = Run
  (<*>) = ap

type Coroutine req rep = Co (SusVal req rep)

resume :: Coroutine req rep a -> rep -> (Coroutine req rep a, req)
resume (Yield (SusVal req s)) rep = (s rep, req)

yield :: req -> Coroutine req rep rep
yield x = Yield $ SusVal x (return)

gen :: Coroutine req () b -> [req]
gen Done = []
gen c = req : (gen c')
  where (c', req) = resume c ()
