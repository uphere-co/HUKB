{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings        #-}
{-# LANGUAGE TemplateHaskell          #-}

module HUKB.PPR where

import           Control.Error.Safe                 (rightMay)
import           Control.Lens                       ((^.),(^..),to)
import           Control.Monad                      ((<=<))
import           Data.ByteString.Char8              (ByteString)
import qualified Data.ByteString.Char8        as B  (packCString,useAsCString)
import           Data.Maybe                         (catMaybes)
import           Data.Monoid                        ((<>))
import           Data.Text                          (Text)
import qualified Data.Text                    as T
import qualified Data.Text.Encoding           as TE
import qualified Data.Text.Encoding.Error     as TE
import           Data.Text.Read                     (decimal)
import           Foreign.C.String
import           Foreign.C.Types
import           Foreign.Ptr                        (Ptr,castPtr)
--
import           WordNet.Type.POS
import           STD.Deletable
import           STD.CppString
import           STD.Ostream
--
import           HUKB.Binding
import           HUKB.Binding.Vector.Template
import qualified HUKB.Binding.Vector.TH       as TH
--
import           HUKB.Type


$(TH.genVectorInstanceFor ''CFloat "float")
$(TH.genVectorInstanceFor ''CWord "CWord")

foreign import ccall "set_global" c_set_global :: CString -> IO ()

foreign import ccall "get_cout" c_get_cout :: IO (Ptr ())

foreign import ccall "get_vec_cword_from_csentence" c_get_vec_cword_from_csentence :: Ptr () -> IO (Ptr ())

pos2Text POS_N = "n"
pos2Text POS_V = "v"
pos2Text POS_A = "a"
pos2Text POS_R = "r"

convertContextWord2Text cw = cw^.cw_word <> "#" <>
                             cw^.cw_pos.to pos2Text <> "#" <>
                             cw^.cw_label.to show.to T.pack <> "#" <>
                             cw^.cw_n.to show.to T.pack


createUKBDB :: (FilePath,FilePath) -> IO () -- UKBDB
createUKBDB (binfile,dictfile) =
  withCString binfile $ \cstr_bin -> do
    withCString dictfile $ \cstr_dict -> do
      str_bin <- newCppString cstr_bin
      kbcreate_from_binfile str_bin
      c_set_global cstr_dict

--
-- | Be careful. I am using global variables here.
--
ppr :: Context -> IO (UKBResult Text)
ppr c = do
  let cid = c^.context_name
      ctxt = T.intercalate " " (c^..context_words.traverse.to convertContextWord2Text)
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
          let gettext = fmap (TE.decodeUtf8With TE.lenientDecode) . B.packCString <=< cppStringc_str
              getint  = fmap (fmap fst . rightMay . decimal) . gettext
          sid <- (gettext <=< cSentenceid) sent

          ws <- mapM (at v) [0..n-1]
          quads <- fmap catMaybes . flip mapM ws $ \x -> do mi <- getint =<< cWordid x
                                                            case mi of
                                                              Nothing -> return Nothing
                                                              Just i -> fmap Just (UKBRW i <$> (gettext =<< cWordwpos x)
                                                                                           <*> (gettext =<< cWordsyn x 0)
                                                                                           <*> (gettext =<< cWordword x))
          delete str_kaka
          delete str_null
          return (UKBResult sid quads)
