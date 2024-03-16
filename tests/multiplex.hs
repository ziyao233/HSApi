module Main where

import Foreign.C.Error
import Foreign.C.Types
import Foreign.C.String
import Foreign.Marshal.Alloc
import Foreign.Storable

import HSApi.OS.File
import HSApi.OS.Socket
import HSApi.OS.Multiplex

instance Show Errno where
  show (Errno x) = '-' : show x

checkRight :: Show a => String -> Either a b -> IO b
checkRight msg (Left a) = error $ msg ++ ": " ++ show a
checkRight _ (Right b) = return b

testStr = "this is a test\n"

main = do
  watcher <- new 1023 1023

  sock <- socket >>= checkRight "create socket"
  bind sock "::1" 11451 >>= checkRight "bind socket"
  listen sock 1024 >>= checkRight "listen socket"

  conn <- accept sock >>= checkRight "accept connection"
  watch watcher conn Writable >>= checkRight "watch connection"

  wait watcher 0 >>= checkRight "wait on watcher"
  conn' <- peek (get watcher)
  if conn /= conn'
  then error $ "mismatched connection: " ++ show conn'
  else return ()

  buf <- newCString $ testStr
  fWrite conn' buf (length testStr)
  free buf

  fClose conn'
  fClose sock
  destroy watcher
