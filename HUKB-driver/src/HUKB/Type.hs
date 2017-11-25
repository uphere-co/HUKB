module HUKB.Type where

import Control.Lens

data UKBDB = UKBDB { _ukbdb_c_bin :: CString
                   , _ukddb_cpp_bin :: CppSting
                   , _ukbdb_c_dict :: CString
                   , _ukbdb_cpp_dict :: CppString
                   }

makeLenses ''UKBDB

createUKBDB :: (FilePath,FilePath) -> IO UKBDB
createUKBDB =
  newCString 
