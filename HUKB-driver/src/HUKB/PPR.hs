{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE TemplateHaskell #-}

module HUKB.PPR where

import           Foreign.C.String
import           Foreign.C.Types
import           Foreign.Ptr (Ptr,castPtr)
--
import           HUKB.Binding
import           HUKB.Binding.Vector.Template 
import qualified HUKB.Binding.Vector.TH       as TH



$(TH.genVectorInstanceFor ''CFloat "float")

foreign import ccall "set_global" c_set_global :: CString -> IO ()

foreign import ccall "get_cout" c_get_cout :: IO (Ptr ())


ppr :: FilePath -> FilePath -> String -> String -> IO ()
ppr binfile dictfile cid sent = do
  withCString binfile $ \cstr_bin -> do
    withCString dictfile $ \cstr_dict -> do
      withCString "kaka" $ \cstr_kaka -> do
        withCString "" $ \cstr_null -> do
          withCString cid $ \cstr_cid -> do
            withCString sent $ \cstr_ctxt -> do
              str_bin <- newCppString cstr_bin
              str_kaka <- newCppString cstr_kaka
              str_null <- newCppString cstr_null
              kbcreate_from_binfile str_bin
              c_set_global cstr_dict
              wDictinstance >>= \r -> wDictget_entries r str_kaka str_null
              sent <- newCSentence cstr_cid cstr_ctxt
              ranks <- newVector 
              calculate_kb_ppr sent ranks
              disamb_csentence_kb sent ranks
              p_cout <- c_get_cout
              let cout = Ostream (castPtr p_cout)
              cSentenceprint_csent sent cout
              return ()
