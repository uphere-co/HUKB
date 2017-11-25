{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings        #-}
{-# LANGUAGE TemplateHaskell          #-}

module HUKB.PPR where

import           Control.Monad                      ((<=<))
import           Data.ByteString.Char8              (ByteString) 
import qualified Data.ByteString.Char8        as B  (packCString,useAsCString)
import           Data.Text                          (Text)
import qualified Data.Text.Encoding           as TE
import           Foreign.C.String
import           Foreign.C.Types
import           Foreign.Ptr                        (Ptr,castPtr)
--
import           HUKB.Binding
import           HUKB.Binding.Vector.Template 
import qualified HUKB.Binding.Vector.TH       as TH
--
-- import           HUKB.Type


$(TH.genVectorInstanceFor ''CFloat "float")
$(TH.genVectorInstanceFor ''CWord "CWord")

foreign import ccall "set_global" c_set_global :: CString -> IO ()

foreign import ccall "get_cout" c_get_cout :: IO (Ptr ())

foreign import ccall "get_vec_cword_from_csentence" c_get_vec_cword_from_csentence :: Ptr () -> IO (Ptr ())


ppr1 :: (CppString,CString) -> (Text,Text) -> IO (ByteString,[(ByteString,ByteString,ByteString,ByteString)])
ppr1 (str_bin,cstr_dict) (cid,ctxt) =
  withCString "kaka" $ \cstr_kaka -> do
    withCString "" $ \cstr_null -> do
      str_kaka <- newCppString cstr_kaka
      str_null <- newCppString cstr_null
      let bstr_cid  = TE.encodeUtf8 cid
          bstr_ctxt = TE.encodeUtf8 ctxt
      B.useAsCString bstr_cid $ \cstr_cid -> do
        B.useAsCString bstr_ctxt $ \cstr_ctxt -> do
          wDictinstance >>= \r -> wDictget_entries r str_kaka str_null
          sent@(CSentence psent) <- newCSentence cstr_cid cstr_ctxt
          ranks <- newVector 
          calculate_kb_ppr sent ranks
          disamb_csentence_kb sent ranks
          p_cout <- c_get_cout
          let cout = Ostream (castPtr p_cout)
          -- cSentenceprint_csent sent cout
          pvw <- c_get_vec_cword_from_csentence (castPtr psent)
          let v = Vector (castPtr pvw) :: Vector CWord
          n <- size v
          let getbstr = B.packCString <=< cppStringc_str
          sid <- (getbstr <=< cSentenceid) sent

          ws <- mapM (at v) [0..n-1]
          quads <- mapM (\x -> (,,,) <$> (getbstr =<< cWordid x)
                                     <*> (getbstr =<< cWordwpos x)
                                     <*> (getbstr =<< cWordsyn x 0)
                                     <*> (getbstr =<< cWordword x)) ws
          delete str_kaka
          delete str_null
          return (sid,quads)



ppr :: FilePath -> FilePath -> (Text,Text)
    -> IO (ByteString,[(ByteString,ByteString,ByteString,ByteString)])
ppr binfile dictfile (cid,ctxt) = do
  withCString binfile $ \cstr_bin -> do
    withCString dictfile $ \cstr_dict -> do
      withCString "kaka" $ \cstr_kaka -> do
        -- withCString "" $ \cstr_null -> do
          -- withCString cid $ \cstr_cid -> do
            --withCString sent $ \cstr_ctxt -> do
        str_bin <- newCppString cstr_bin
        -- str_kaka <- newCppString cstr_kaka
        -- str_null <- newCppString cstr_null
        kbcreate_from_binfile str_bin
        c_set_global cstr_dict
        ppr1 (str_bin,cstr_dict) (cid,ctxt)

{-               
              wDictinstance >>= \r -> wDictget_entries r str_kaka str_null
              sent@(CSentence psent) <- newCSentence cstr_cid cstr_ctxt
              ranks <- newVector 
              calculate_kb_ppr sent ranks
              disamb_csentence_kb sent ranks
              p_cout <- c_get_cout
              let cout = Ostream (castPtr p_cout)
              -- cSentenceprint_csent sent cout
              pvw <- c_get_vec_cword_from_csentence (castPtr psent)
              let v = Vector (castPtr pvw) :: Vector CWord
              n <- size v
              let getbstr = B.packCString <=< cppStringc_str
              sid <- (getbstr <=< cSentenceid) sent
              
              ws <- mapM (at v) [0..n-1]
              quads <- mapM (\x -> (,,,) <$> (getbstr =<< cWordid x)
                                         <*> (getbstr =<< cWordwpos x)
                                         <*> (getbstr =<< cWordsyn x 0)
                                         <*> (getbstr =<< cWordword x)) ws
              delete str_kaka
              return (sid,quads)
-}
