-- HSApi
-- /HSApi/OS/Multiplex.hs
-- This file is distributed under Mozilla Public License Version 2.0
-- Copyright (c) 2024 Yao Zi. All rights reserved.

{-# Language ForeignFunctionInterface #-}

module HSApi.OS.Multiplex where

import Foreign
import Foreign.C.Error
import Foreign.C.String
import Foreign.C.Types

import HSApi.OS.File (Handler)

import Control.Monad.Trans.Class
import Control.Monad.Trans.Maybe

type RawWatcher = Ptr ()
type WatcherRef = (RawWatcher, Ptr Handler, Int)

foreign import ccall "OS/CMultiplex.c hsapi_watcher_new"
  new_ :: CUInt -> IO RawWatcher

foreign import ccall "OS/CMultiplex.c hsapi_watcher_watch"
  watch_ :: RawWatcher -> Handler -> CInt -> IO CInt

foreign import ccall "OS/CMultiplex.c hsapi_watcher_wait"
  wait_ :: RawWatcher -> Ptr CInt -> CSize -> CInt -> IO CInt

foreign import ccall "OS/CMultiplex.c hsapi_watcher_unwatch"
  unwatch_ :: RawWatcher -> Handler -> IO CInt

foreign import ccall "OS/CMultiplex.c hsapi_watcher_destroy"
  destroy_ :: RawWatcher -> IO ()

data EventType = Readable | Writable | Available

toCEventType :: EventType -> CInt
toCEventType Readable  = CInt 1
toCEventType Writable  = CInt 2
toCEventType Available = CInt 3

eitherErrno :: CInt -> IO (Either Errno ())
eitherErrno x
 | x < 0     = getErrno >>= return . Left
 | otherwise = return $ Right ()

new :: Int -> Int -> IO WatcherRef
new a b = do
  raw <- new_ $ CUInt $ fromIntegral a
  hs <- mallocBytes $ (b + 1) * sizeOf (CInt undefined)
  return (raw, hs, b)

watch :: WatcherRef -> Handler -> EventType -> IO (Either Errno ())
watch (r, _, _) h t = watch_ r h (toCEventType t) >>= eitherErrno

unwatch :: WatcherRef -> Handler -> IO (Either Errno ())
unwatch (r, _, _) h = unwatch_ r h >>= eitherErrno

wait :: WatcherRef -> Int -> IO (Either Errno Int)
wait (r, p, l) t = wait_ r p size time >>= check
  where check x
         | x < 0     = getErrno >>= return . Left
         | otherwise = return $ Right $ fromIntegral x
        size = CSize $ fromIntegral l
        time = CInt $ fromIntegral t

get :: WatcherRef -> Ptr Handler
get (_, p, _) = p

destroy :: WatcherRef -> IO ()
destroy (w, hs, _) = (destroy_ w) >> (free hs)
