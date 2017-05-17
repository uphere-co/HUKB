{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import           Control.Applicative ((<$>))
import           Foreign.C.String
import           Foreign.C.Types
import           Options.Applicative
--
import           HUKB.Binding
import           HUKB.Binding.Vector.Template 
import qualified HUKB.Binding.Vector.TH       as TH


$(TH.genVectorInstanceFor ''CFloat "float")

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
          withCString "ctx_01" $ \cstr_cid -> do
            withCString "man#n#w1#1 kill#v#w2#1 cat#n#w3#1 hammer#n#w4#1" $ \cstr_ctxt -> do
              str_bin <- newCppString cstr_bin
              -- str_dict <- newCppString cstr_dict
              str_kaka <- newCppString cstr_kaka
              str_null <- newCppString cstr_null
              -- str_cid <- newCppString cstr_cid
              -- str_ctxt <- newCppString cstr_ctxt
              kbcreate_from_binfile str_bin
              c_set_global cstr_dict
              wDictinstance >>= \r -> wDictget_entries r str_kaka str_null
              sent <- newCSentence cstr_cid cstr_ctxt
              ranks <- newVector 
              calculate_kb_ppr sent ranks
              -- ppr_csent   -> ukb_wsd
              -- calculate_kb_ppr -> csentence top-level
              -- disamb_csentence_kb -> csentence top-level
              return ()
