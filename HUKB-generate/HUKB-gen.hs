module Main where

import Data.Monoid (mempty)
--
import FFICXX.Generate.Builder
import FFICXX.Generate.Type.Class
import FFICXX.Generate.Type.Module
import FFICXX.Generate.Type.PackageInterface


-- -------------------------------------------------------------------
-- import from stdcxx
-- -------------------------------------------------------------------

-- import from stdcxx
stdcxx_cabal = cabal {- Cabal { cabal_pkgname = "stdcxx"
                     , cabal_cheaderprefix = "STD"
                     , cabal_moduleprefix = "STD"
                     , cabal_additional_c_incs = []
                     , cabal_additional_c_srcs = []
                     , cabal_additional_pkgdeps = []
                     } -}

-- import from stdcxx
deletable :: Class
deletable =
  AbstractClass stdcxx_cabal "Deletable" [] mempty Nothing
  [ Destructor Nothing
  ]

-- import from stdcxx
string :: Class
string =
  Class stdcxx_cabal "string" [ deletable ] mempty  (Just "CppString")
  [ Constructor [ cstring "p" ] Nothing
  , NonVirtual cstring_ "c_str" [] Nothing
  , NonVirtual (cppclassref_ string) "append" [cppclassref string "str"] Nothing
  , NonVirtual (cppclassref_ string) "erase" [] Nothing
  ]

-- import from stdcxx
ostream :: Class
ostream =
  Class cabal "ostream" [] mempty (Just "Ostream")
  [
  ]


-- -------------------------------------------------------------------
-- HUKB definition
-- -------------------------------------------------------------------


cabal = Cabal { cabal_pkgname = "HUKB"
              , cabal_cheaderprefix = "HUKB"
              , cabal_moduleprefix = "HUKB.Binding"
              , cabal_additional_c_incs = []
              , cabal_additional_c_srcs = []
              , cabal_additional_pkgdeps = [] -- [ CabalName "stdcxx" ]
              }

extraDep = []

cabalattr =
    CabalAttr
    { cabalattr_license = Just "BSD3"
    , cabalattr_licensefile = Just "LICENSE"
    , cabalattr_extraincludedirs = [ ]
    , cabalattr_extralibdirs = []
    , cabalattr_extrafiles = []
    }


-- Kb is not deletable since destructor is defined as a private method.
kb :: Class
kb =
  Class cabal "Kb" [ ] mempty Nothing
  [ Static void_ "create_from_binfile" [ cppclassref string "o" ] Nothing
  ]

wdict_entries :: Class
wdict_entries =
  Class cabal "WDict_entries" [ deletable ] mempty Nothing
  [
  ]

wdict :: Class
wdict =
  Class cabal "WDict" [ deletable ] mempty Nothing
  [ Static     (cppclassref_ wdict)         "instance"    [ ] Nothing
  , NonVirtual (cppclasscopy_ wdict_entries) "get_entries"
      [ cppclassref string "word", cppclassref string "pos" ] Nothing
  ]

vectorfloatref_ = TemplateAppRef t_vector "CFloat" "std::vector<float>"

cword :: Class
cword =
  Class cabal "CWord" [ deletable ] mempty Nothing
  [ NonVirtual (cppclasscopy_ string) "word" [] Nothing
  , NonVirtual (cppclasscopy_ string) "wpos" [] Nothing
  , NonVirtual (cppclasscopy_ string) "id" [] Nothing
  , NonVirtual (cppclasscopy_ string) "syn" [int "i"] Nothing
  ]

csentence :: Class
csentence =
  Class cabal "CSentence" [ deletable ] mempty Nothing
  [ Constructor [ cstring "id" , cstring "ctx_str" ] Nothing
  , NonVirtual (cppclassref_ ostream) "print_csent" [ cppclassref ostream "o" ] Nothing
  , NonVirtual (cppclasscopy_ string) "id" [] Nothing
  -- , NonVirtual (cppclassref_ csentenceConstIterator) "ubegin" [] Nothing
  -- , NonVirtual (cppclassref_ csentenceConstIterator) "uend" [] Nothing
  ]

{-
csentenceConstIterator :: Class
csentenceConstIterator =
  Class cabal "CSentence::const_iterator" [] mempty (Just "CSentenceConstIterator")
  [
  ]
-}

classes = [ deletable, string,ostream  -- temporary
          , kb,wdict_entries,wdict,csentence,cword

          -- , csentenceConstIterator
          ]

toplevelfunctions =
  [ TopLevelFunction bool_ "calculate_kb_ppr" [cppclassref csentence "cs", (vectorfloatref_, "ranks") ] Nothing
  , TopLevelFunction bool_ "disamb_csentence_kb" [cppclassref csentence "cs", (vectorfloatref_, "ranks") ] Nothing
  ]

t_vector = TmplCls cabal "Vector" "std::vector" "t"
             [ TFunNew []
             , TFun void_ "push_back" "push_back" [(TemplateParam "t","x")] Nothing
             , TFun void_ "pop_back"  "pop_back"  []                        Nothing
             , TFun (TemplateParam "t") "at" "at" [int "n"]                 Nothing
             , TFun int_  "size"      "size"      []                        Nothing
             , TFunDelete
             ]



templates = [ (t_vector, HdrName "Vector.h") ]

headerMap = [ ("Kb"           , ([NS "ukb", NS "std"], [HdrName "kbGraph.h"]))
            , ("WDict_entries", ([NS "ukb", NS "std"], [HdrName "wdict.h"  ]))
            , ("WDict"        , ([NS "ukb", NS "std"], [HdrName "wdict.h"  ]))
            , ("CSentence"    , ([NS "ukb", NS "std"], [HdrName "csentence.h"]))
            , ("CWord"        , ([NS "ukb", NS "std"], [HdrName "csentence.h", HdrName "string"]))
            , ("string"       , ([NS "std"          ], [HdrName "string"   ]))
            ]

main :: IO ()
main = do
  simpleBuilder "HUKB.Binding" headerMap (cabal,cabalattr,classes,toplevelfunctions,templates)
    [ "ukb", "boost_random", "boost_filesystem", "boost_system" ] extraDep
