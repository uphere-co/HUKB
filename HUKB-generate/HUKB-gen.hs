module Main where

import qualified Data.HashMap.Strict as HM ( fromList )
import           Data.Monoid               ( mempty )
--
import FFICXX.Generate.Builder
import FFICXX.Generate.Code.Primitive
import FFICXX.Generate.Type.Cabal          ( Cabal(..)
                                           , CabalName(..)
                                           , AddCInc(..)
                                           , AddCSrc(..)
                                           )
import FFICXX.Generate.Type.Config         ( ModuleUnit(..)
                                           , ModuleUnitMap(..)
                                           , ModuleUnitImports(..)
                                           )
import FFICXX.Generate.Type.Class
import FFICXX.Generate.Type.Module
import FFICXX.Generate.Type.PackageInterface

-- -------------------------------------------------------------------
-- import from stdcxx
-- -------------------------------------------------------------------

-- import from stdcxx
stdcxx_cabal = Cabal { cabal_pkgname = CabalName "stdcxx"
                     , cabal_cheaderprefix = "STD"
                     , cabal_moduleprefix = "STD"
                     , cabal_additional_c_incs = []
                     , cabal_additional_c_srcs = []
                     , cabal_additional_pkgdeps = []
                     , cabal_pkg_config_depends = []
                     }

-- import from stdcxx
-- NOTE: inheritable class import needs method.
deletable :: Class
deletable =
  AbstractClass stdcxx_cabal "Deletable" [] mempty Nothing
    [ Destructor Nothing ]
    []
    []

-- import from stdcxx
string :: Class
string =
  Class stdcxx_cabal "string" [ deletable ] mempty
  (Just (ClassAlias { caHaskellName = "CppString", caFFIName = "string"}))
  []
  []
  []

-- import from stdcxx
ostream :: Class
ostream =
  Class stdcxx_cabal "ostream" [] mempty
  (Just (ClassAlias { caHaskellName = "Ostream", caFFIName = "ostream" }))
  []
  []
  []

t_vector = TmplCls stdcxx_cabal "Vector" "std::vector" "t" [ ]

-- -------------------------------------------------------------------
-- HUKB definition
-- -------------------------------------------------------------------


cabal =
  Cabal { cabal_pkgname = CabalName "HUKB"
        , cabal_version = "0.0"
        , cabal_cheaderprefix = "HUKB"
        , cabal_moduleprefix = "HUKB.Binding"
        , cabal_additional_c_incs = []
        , cabal_additional_c_srcs = []
        , cabal_additional_pkgdeps = [ CabalName "stdcxx" ]
        , cabal_license = Just "BSD3"
        , cabal_licensefile = Just "LICENSE"
        , cabal_extraincludedirs = [ ]
        , cabal_extralibdirs = []
        , cabal_extrafiles = []
        , cabal_pkg_config_depends = []
        }

extraDep = []



-- Kb is not deletable since destructor is defined as a private method.
kb :: Class
kb =
  Class cabal "Kb" [ ] mempty Nothing
  [ Static void_ "create_from_binfile" [ cppclassref string "o" ] Nothing ]
  []
  []

wdict_entries :: Class
wdict_entries =
  Class cabal "WDict_entries" [ deletable ] mempty Nothing
  []
  []
  []


wdict :: Class
wdict =
  Class cabal "WDict" [ deletable ] mempty Nothing
  [ Static     (cppclassref_ wdict)         "instance"    [ ] Nothing
  , NonVirtual (cppclasscopy_ wdict_entries) "get_entries"
      [ cppclassref string "word", cppclassref string "pos" ] Nothing
  ]
  []
  []


vectorfloatref_ =
  TemplateAppRef
    (TemplateAppInfo {
       tapp_tclass = t_vector
     , tapp_tparam = TArg_Other "CFloat"
     , tapp_CppTypeForParam = "std::vector<float>"
     })


cword :: Class
cword =
  Class cabal "CWord" [ deletable ] mempty Nothing
  [ NonVirtual (cppclasscopy_ string) "word" [] Nothing
  , NonVirtual (cppclasscopy_ string) "wpos" [] Nothing
  , NonVirtual (cppclasscopy_ string) "id" [] Nothing
  , NonVirtual (cppclasscopy_ string) "syn" [int "i"] Nothing
  ]
  []
  []

csentence :: Class
csentence =
  Class cabal "CSentence" [ deletable ] mempty Nothing
  [ Constructor [ cstring "id" , cstring "ctx_str" ] Nothing
  , NonVirtual (cppclassref_ ostream) "print_csent" [ cppclassref ostream "o" ] Nothing
  , NonVirtual (cppclasscopy_ string) "id" [] Nothing
  -- , NonVirtual (cppclassref_ csentenceConstIterator) "ubegin" [] Nothing
  -- , NonVirtual (cppclassref_ csentenceConstIterator) "uend" [] Nothing
  ]
  []
  []

{-
csentenceConstIterator :: Class
csentenceConstIterator =
  Class cabal "CSentence::const_iterator" [] mempty (Just "CSentenceConstIterator")
  [
  ]
-}

classes = [ kb,wdict_entries,wdict,csentence,cword
          -- , csentenceConstIterator
          ]

toplevelfunctions =
  [ TopLevelFunction bool_ "calculate_kb_ppr" [cppclassref csentence "cs", (vectorfloatref_, "ranks") ] Nothing
  , TopLevelFunction bool_ "disamb_csentence_kb" [cppclassref csentence "cs", (vectorfloatref_, "ranks") ] Nothing
  ]


templates = [ ]

headerMap =
  ModuleUnitMap $
    HM.fromList $
      [ ( MU_Class "Kb"
        , ModuleUnitImports {
            muimports_namespaces = [NS "ukb", NS "std"]
          , muimports_headers = [HdrName "kbGraph.h"]
          }
        )
      , ( MU_Class "WDict_entries"
        , ModuleUnitImports {
            muimports_namespaces = [NS "ukb", NS "std"]
          , muimports_headers = [HdrName "wdict.h"  ]
          }
        )
      , ( MU_Class "WDict"
        , ModuleUnitImports {
            muimports_namespaces = [NS "ukb", NS "std"]
          , muimports_headers = [HdrName "wdict.h"  ]
          }
        )
      , ( MU_Class "CSentence"
        , ModuleUnitImports {
            muimports_namespaces = [NS "ukb", NS "std"]
          , muimports_headers = [HdrName "csentence.h"]
          }
        )
      , ( MU_Class "CWord"
        , ModuleUnitImports {
            muimports_namespaces = [NS "ukb", NS "std"]
          , muimports_headers = [HdrName "csentence.h", HdrName "string"]
          }
        )
      ]

main :: IO ()
main = do
  simpleBuilder
    "HUKB.Binding"
    headerMap
    (cabal,classes,toplevelfunctions,templates)
    [ "ukb", "boost_random", "boost_filesystem", "boost_system" ]
    extraDep
