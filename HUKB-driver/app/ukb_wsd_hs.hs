{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings        #-}
{-# LANGUAGE TemplateHaskell          #-}

module Main where

import           Control.Applicative      ((<$>))
import           Data.Monoid              ((<>))
import qualified Data.Text           as T
import           Options.Applicative
--
import           WordNet.Type.POS
--
import           HUKB.PPR
import           HUKB.Type


data ProgOption = ProgOption { kb_binfile :: FilePath
                             , dict_file :: FilePath
                             } deriving Show

pOptions :: Parser ProgOption
pOptions =
  ProgOption <$> strOption (long "kb_binfile" <> short 'K' <> help "Binary file of KB")
             <*> strOption (long "dict_file" <> short 'D' <> help "Dictionary text file")


progOption :: ParserInfo ProgOption
progOption = info pOptions (fullDesc <> progDesc "UKB word sense disambiguation")


cwords = zipWith f [1..] [ ("Britain",POS_N), ("cut",POS_V), ("stamp",POS_N), ("duty",POS_N), ("property",POS_N), ("tax",POS_N)
                         , ("buyer",POS_N), ("bid",POS_N), ("help",POS_V), ("people",POS_N), ("struggle",POS_V), ("get",POS_V)
                         , ("property",POS_N), ("ladder",POS_N), ("finance",POS_N), ("minister",POS_N), ("Philip",POS_N)
                         , ("Hammond",POS_N), ("say",POS_V), ("Wednesday",POS_N) ]
  where f i (w,p) = CtxtWord w p (T.pack ("w"++show i)) 1
{-
("ctx_01"
                ,"Britain#n#w1#1 cut#v#w2#1 stamp#n#w3#1 duty#n#w4#1 property#n#w5#1 tax#n#w6#1 buyer#n#w7#1 bid#n#w8#1 help#v#w9#1 people#n#w10#1 struggle#v#w11#1 get#v#w12#1 property#n#w13#1 ladder#n#w14#1 finance#n#w15#1 minister#n#w16#1 Philip#n#w17#1 Hammond#n#w18#1 say#v#w19#1 Wednesday#n#w20#1")
-}

main = do
  opt <- execParser progOption
  createUKBDB (kb_binfile opt,dict_file opt)
  let ctxt = Context "ctx_01" cwords


  result <- ppr ctxt
  print result

  -- "man#n#w1#1 kill#v#w2#1 cat#n#w3#1 hammer#n#w4#1"
