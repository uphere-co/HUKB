{-# LANGUAGE TemplateHaskell #-}

module HUKB.Type where

import           Control.Lens          (makeLenses)
import           Data.ByteString.Char8 (ByteString)
import           Data.Text             (Text)
import           Foreign.C.String
--
import           WordNet.Type.POS
--
import           HUKB.Binding


data UKBDB = UKBDB { _ukddb_bin :: CppString
                   , _ukbdb_dict :: CString
                   }

makeLenses ''UKBDB

data ContextWord = CtxtWord { _cw_word  :: Text
                            , _cw_pos   :: POS
                            , _cw_label :: Text
                            , _cw_n     :: Int }

makeLenses ''ContextWord


data Context = Context { _context_name :: Text
                       , _context_words :: [ContextWord] }

makeLenses ''Context


data UKBResultWord = UKBRW { _ukbrw_id   :: Text
                           , _ukbrw_wpos :: Text
                           , _ukbrw_syn  :: Text
                           , _ukbrw_word :: Text
                           }
                   deriving Show



makeLenses ''UKBResultWord

data UKBResult = UKBResult { _ukbresult_sentid :: Text
                           , _ukbresult_words :: [UKBResultWord]
                           }
                 deriving Show

makeLenses ''UKBResult
