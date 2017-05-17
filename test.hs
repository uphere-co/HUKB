module Main where

import Foreign.C.String
--
import HUKB.Binding



main = do
  putStrLn "HUKB test"
  withCString "test.dat" $ \cstr -> do
    str <- newCppString cstr
    kbcreate_from_binfile str
