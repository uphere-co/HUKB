module Main where

import           Control.Applicative ((<$>))
import           Foreign.C.String
import           Options.Applicative
--
import           HUKB.Binding

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
  withCString (kb_binfile opt) $ \cstr -> do
    str <- newCppString cstr
    kbcreate_from_binfile str
