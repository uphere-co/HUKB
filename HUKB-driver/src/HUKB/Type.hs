{-# LANGUAGE TemplateHaskell #-}

module HUKB.Type where

import           Control.Lens          (makeLenses)
import           Data.Text             (Text)
import           Foreign.C.String
--
import           WordNet.Type.POS
--
import           STD.CppString


data UKBDB = UKBDB { _ukddb_bin :: CppString
                   , _ukbdb_dict :: CString
                   }

makeLenses ''UKBDB

data ContextWord = CtxtWord { _cw_word  :: Text
                            , _cw_pos   :: POS
                            , _cw_label :: Int
                            , _cw_n     :: Int }
                 deriving (Show)

makeLenses ''ContextWord


data Context = Context { _context_name :: Text
                       , _context_words :: [ContextWord] }
               deriving (Show)

makeLenses ''Context


data UKBResultWord s = UKBRW { _ukbrw_id   :: Int
                             , _ukbrw_wpos :: Text
                             , _ukbrw_syn  :: s
                             , _ukbrw_word :: Text
                           }
                   deriving Show



makeLenses ''UKBResultWord

data UKBResult s = UKBResult { _ukbresult_sentid :: Text
                             , _ukbresult_words :: [UKBResultWord s]
                             }
                 deriving Show

makeLenses ''UKBResult
