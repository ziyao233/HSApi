-- HSApi.OS.File
-- /HSApi/OS/File.hs
-- This file is distributed under Mozilla Public License Version 2.0
-- Copyright (c) 2024 Yao Zi. All rights reserved.

{-# Language ForeignFunctionInterface #-}

module HSApi.OS.File where

import Foreign
import Foreign.C.Error
import Foreign.C.String
import Foreign.C.Types

import Control.Monad.Trans.Class
import Control.Monad.Trans.Maybe

type Handler = Int

foreign import ccall "unistd.h close"
  close_ :: Handler -> IO Int
foreign import ccall "unistd.h read"
  read_ :: Handler -> Ptr CChar -> Int -> IO Int
foreign import ccall "unistd.h write"
  write_ :: Handler -> Ptr CChar -> Int -> IO Int
foreign import ccall "unistd.h dup"
  dup_ :: Handler -> IO Handler
foreign import ccall "unistd.h fileno"
  fileno_ :: Ptr () -> IO (Int)
foreign import ccall "unistd.h fopen"
  fopen_ :: CString -> CString -> IO (Ptr ())
foreign import ccall "unistd.h fclose"
  fclose_ :: Ptr () -> IO Int

eitherErrno :: IO (Either Errno a)
eitherErrno = getErrno >>= return . Left

fOpen :: String -> String -> IO (Either Errno Handler)
fOpen path mode =
  runMaybeT (do
    path' <- lift $ newCString path
    mode' <- lift $ newCAString mode
    fp <- lift $ fopen_ path' mode'
    lift $ free path'
    lift $ free mode'
    checkPtr fp
    h  <- lift $ fileno_ fp
    checkRet h
    h' <- lift $ dup_ h
    checkRet h'
    ret <- lift $ fclose_ fp
    checkRet ret
    return h')
  >>= \x -> case x of
    Nothing -> eitherErrno
    Just h' -> return $ Right h'
  where checkPtr p
         | p == nullPtr = return Nothing
         | otherwise    = return $ Just ()
        checkRet h
         | h < 0     = return Nothing
         | otherwise = return $ Just ()

-- TODO: Fix eAGAIN and eWOULDBLOCK
fClose :: Handler -> IO (Either Errno ())
fClose f = close_ f >>= \r ->
  if r == 0 then return $ Right () else eitherErrno

fRead :: Handler -> Ptr CChar -> Int -> IO (Either Errno Int)
fRead f b s = read_ f b s >>= \r ->
  if r >= 0 then return $ Right r else eitherErrno

fWrite :: Handler -> Ptr CChar -> Int -> IO (Either Errno Int)
fWrite f b s = write_ f b s >>= \r ->
  if r >= 0 then return $ Right r else eitherErrno
