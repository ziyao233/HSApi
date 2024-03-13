module Main where

import Foreign.C.Error
import Foreign.C.String
import Foreign.Marshal
import HSApi.OS.File
import HSApi.OS.Socket

instance Show Errno where
  show (Errno x) = "-" ++ (show x)

testStr = "this is a test\n"

checkRight :: String -> Either Errno a -> IO a
checkRight _ (Right x) = return x
checkRight msg (Left e) = error $ msg ++ ": " ++ (show e)

main = do
  sock <- socket >>= checkRight "failed to create socket"
  bind sock "::" 19198 >>= checkRight "failed to bind socket"
  listen sock 1024 >>= checkRight "failed to listen socket"
  conn <- accept sock >>= checkRight "failed to accept socket"
  buf <- newCAString testStr
  fWrite conn buf (length testStr) >>= checkRight "failed to write data"
  free buf
  fClose conn >>= checkRight "failed to close connection"
  fClose sock >>= checkRight "failed to close socket"
