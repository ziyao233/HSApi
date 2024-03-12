module Main where

import Foreign
import Foreign.C.Error
import Foreign.C.String

import HSApi.OS.File

instance Show Errno where
  show (Errno x) = "-" ++ show x

testStr = "this is a test\n"

checkRight :: Show a => Either a b -> IO ()
checkRight (Left a) = error $ show a
checkRight (Right b) = return ()

testCreateFile :: IO ()
testCreateFile = do
  r <- fOpen "test.o" "w"
  h <- case r of
    Left x -> error $ "Cannot open test.o for write: " ++ (show x)
    Right h -> return h
  buf <- newCAString testStr
  fWrite h buf (length testStr) >>= checkRight
  fClose h >>= checkRight
  free buf

testReadFile :: IO ()
testReadFile = do
  r <- fOpen "test.o" "r"
  h <- case r of
    Left x -> error $ "Cannot open test.o for read: " ++ (show x)
    Right h -> return h
  buf <- mallocBytes $ length testStr
  fRead h buf (length testStr) >>= checkRight
  fClose h >>= checkRight
  s <- peekCAStringLen (buf, length testStr)
  free buf
  if s == testStr then return () else error "file content mismatches!"

main :: IO ()
main = do
  testCreateFile
  testReadFile
