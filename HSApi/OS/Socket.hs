-- HSApi.OS.Socket
-- /HSApi/OS/Socket.hs
-- This file is distributed under Mozilla Public License Version 2.0
-- Copyright (c) 2024 Yao Zi.

{-# Language ForeignFunctionInterface #-}
module HSApi.OS.Socket where

import Foreign
import Foreign.C.Error
import Foreign.C.Types
import Foreign.C.String

import HSApi.OS.File (Handler)

type Socket = Handler

foreign import ccall "OS/Socket.c hsapi_socket"
  socket_ :: IO (CInt)
foreign import ccall "OS/Socket.c hsapi_bind"
  bind_ :: CInt -> CString -> CInt -> IO (CInt)
foreign import ccall "OS/Socket.c hsapi_listen"
  listen_ :: CInt -> CInt -> IO (CInt)
foreign import ccall "OS/Socket.c hsapi_accept"
  accept_ :: CInt -> IO (CInt)

eitherErrno :: (CInt, a) -> IO (Either Errno a)
eitherErrno (x, a)
 | x < 0     = getErrno >>= return . Left
 | otherwise = return $ Right a

socket :: IO (Either Errno Socket)
socket = socket_ >>= eitherErrno . rep

rep :: a -> (a, a)
rep a = (a, a)

toCInt = CInt . fromIntegral

bind :: Socket -> String -> Int -> IO (Either Errno ())
bind s a p = do
  a' <- newCAString a
  r <- bind_ s a' (toCInt p)
  free a'
  eitherErrno (r, ())

listen :: Socket -> Int -> IO (Either Errno ())
listen s b = listen_ s (toCInt b) >>= \x -> eitherErrno (x, ())

accept :: Socket -> IO (Either Errno Handler)
accept s = accept_ s >>= eitherErrno . rep
