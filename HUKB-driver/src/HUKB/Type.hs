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


data UKBResultWord = UKBRW { _ukbrw_id :: ByteString
                           , _ukbrw_wpos :: ByteString
                           , _ukbrw_syn :: ByteString
                           , _ukbrw_word :: ByteString
                           }
                   deriving Show



makeLenses ''UKBResultWord

data UKBResult = UKBResult { _ukbresult_sentid :: ByteString
                           , _ukbresult_words :: [UKBResultWord]
                           }
                 deriving Show

makeLenses ''UKBResult
