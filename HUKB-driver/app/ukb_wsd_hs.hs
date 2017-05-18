{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import           Control.Applicative ((<$>))
import           Data.Monoid         ((<>))
import           Options.Applicative
--
import           HUKB.PPR


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
  ppr (kb_binfile opt) (dict_file opt) "ctx_01" "man#n#w1#1 kill#v#w2#1 cat#n#w3#1 hammer#n#w4#1"
