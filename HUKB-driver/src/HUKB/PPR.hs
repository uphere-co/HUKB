{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE TemplateHaskell #-}

module HUKB.PPR where

import           Data.ByteString.Char8        as B  (packCString)
import           Foreign.C.String
import           Foreign.C.Types
import           Foreign.Ptr                        (Ptr,castPtr)
--
import           HUKB.Binding
import           HUKB.Binding.Vector.Template 
import qualified HUKB.Binding.Vector.TH       as TH



$(TH.genVectorInstanceFor ''CFloat "float")
$(TH.genVectorInstanceFor ''CWord "CWord")

foreign import ccall "set_global" c_set_global :: CString -> IO ()

foreign import ccall "get_cout" c_get_cout :: IO (Ptr ())

foreign import ccall "get_vec_cword_from_csentence" c_get_vec_cword_from_csentence :: Ptr () -> IO (Ptr ())


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
              sent@(CSentence psent) <- newCSentence cstr_cid cstr_ctxt
              ranks <- newVector 
              calculate_kb_ppr sent ranks
              disamb_csentence_kb sent ranks
              p_cout <- c_get_cout
              let cout = Ostream (castPtr p_cout)
              cSentenceprint_csent sent cout
              pvw <- c_get_vec_cword_from_csentence (castPtr psent)
              let v = Vector (castPtr pvw) :: Vector CWord
              print =<< size v
              cs <- mapM (at v) [0,1,2,3]
              ss <- mapM cWordword cs
              cstrs <- mapM cppStringc_str ss
              bstrs <- mapM packCString cstrs
              mapM_ print bstrs
              return ()
