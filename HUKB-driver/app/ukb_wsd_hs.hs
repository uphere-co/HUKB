{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings        #-}
{-# LANGUAGE TemplateHaskell          #-}

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
  createUKBDB (kb_binfile opt,dict_file opt)
  result <- ppr ("ctx_01"
                ,"Britain#n#w1#1 cut#v#w2#1 stamp#n#w3#1 duty#n#w4#1 property#n#w5#1 tax#n#w6#1 buyer#n#w7#1 bid#n#w8#1 help#v#w9#1 people#n#w10#1 struggle#v#w11#1 get#v#w12#1 property#n#w13#1 ladder#n#w14#1 finance#n#w15#1 minister#n#w16#1 Philip#n#w17#1 Hammond#n#w18#1 say#v#w19#1 Wednesday#n#w20#1")
  print result

  -- "man#n#w1#1 kill#v#w2#1 cat#n#w3#1 hammer#n#w4#1"
