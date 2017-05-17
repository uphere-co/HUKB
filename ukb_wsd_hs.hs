{-# LANGUAGE ForeignFunctionInterface #-}

module Main where

import           Control.Applicative ((<$>))
import           Foreign.C.String
import           Options.Applicative
--
import           HUKB.Binding

foreign import ccall "set_global" c_set_global :: CString -> IO ()

data ProgOption = ProgOption { kb_binfile :: FilePath
                             , dict_file :: FilePath
                             } deriving Show

pOptions :: Parser ProgOption
pOptions =
  ProgOption <$> strOption (long "kb_binfile" <> short 'K' <> help "Binary file of KB")
             <*> strOption (long "dict_file" <> short 'D' <> help "Dictionary text file")


progOption :: ParserInfo ProgOption 
progOption = info pOptions (fullDesc <> progDesc "UKB word sense disambiguation")



main = do
  opt <- execParser progOption
  withCString (kb_binfile opt) $ \cstr_bin -> do
    withCString (dict_file opt) $ \cstr_dict -> do
      withCString "kaka" $ \cstr_kaka -> do
        withCString "" $ \cstr_null -> do
          str_bin <- newCppString cstr_bin
          -- str_dict <- newCppString cstr_dict
          str_kaka <- newCppString cstr_kaka
          str_null <- newCppString cstr_null
          kbcreate_from_binfile str_bin
          c_set_global cstr_dict
          r <- wDictinstance
          wDictget_entries r str_kaka str_null 
          return ()
