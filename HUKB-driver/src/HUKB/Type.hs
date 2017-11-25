{-# LANGUAGE TemplateHaskell #-}

module HUKB.Type where

import           Control.Lens
import           Foreign.C.String
--
import           HUKB.Binding


data UKBDB = UKBDB { _ukddb_bin :: CppString
                   , _ukbdb_dict :: CString
                   }

makeLenses ''UKBDB
