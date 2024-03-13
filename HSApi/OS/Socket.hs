-- HSApi.OS.Socket
-- /HSApi/OS/Socket.hs
-- This file is distributed under Mozilla Public License Version 2.0
-- Copyright (c) 2024 Yao Zi.

{-# Language ForeignFunctionInterface #-}
module HSApi.OS.Socket where

import Foreign
import Foreign.C.Error
import Foreign.C.String

import HSApi.OS.File (Handler)

type Socket = Handler

foreign import ccall "OS/Socket.c hsapi_socket"
  socket_ :: IO (Int)
foreign import ccall "OS/Socket.c hsapi_bind"
  bind_ :: Int -> CString -> Int -> IO (Int)
foreign import ccall "OS/Socket.c hsapi_listen"
  listen_ :: Int -> Int -> IO (Int)
foreign import ccall "OS/Socket.c hsapi_accept"
  accept_ :: Int -> IO (Int)

eitherErrno :: (Int, a) -> IO (Either Errno a)
eitherErrno (x, a)
 | x < 0     = getErrno >>= return . Left
 | otherwise = return $ Right a

socket :: IO (Either Errno Socket)
socket = socket_ >>= eitherErrno . rep

rep :: a -> (a, a)
rep a = (a, a)

bind :: Socket -> String -> Int -> IO (Either Errno ())
bind s a p = do
  a' <- newCAString a
  r <- bind_ s a' p
  free a'
  eitherErrno (r, ())

listen :: Socket -> Int -> IO (Either Errno ())
listen s b = listen_ s b >>= \x -> eitherErrno (x, ())

accept :: Socket -> IO (Either Errno Handler)
accept s = accept_ s >>= eitherErrno . rep
