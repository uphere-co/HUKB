module Main where

import Data.Monoid (mempty)
--
import FFICXX.Generate.Builder
import FFICXX.Generate.Type.Class
import FFICXX.Generate.Type.Module
import FFICXX.Generate.Type.PackageInterface


cabal = Cabal { cabal_pkgname = "HUKB" 
              , cabal_cheaderprefix = "HUKB"
              , cabal_moduleprefix = "HUKB.Binding" }

extraDep = []

cabalattr = 
    CabalAttr 
    { cabalattr_license = Just "BSD3"
    , cabalattr_licensefile = Just "LICENSE"
    , cabalattr_extraincludedirs = [ ]
    , cabalattr_extralibdirs = []
    , cabalattr_extrafiles = []
    }


string :: Class 
string = 
  Class cabal "string" [] mempty  (Just "CppString")
  [ Constructor [ cstring "p" ] Nothing
  ]  

kb :: Class
kb =
  Class cabal "Kb" [] mempty Nothing
  [ Static void_ "create_from_binfile" [ cppclassref string "o" ] Nothing
  ]

wdict_entries :: Class
wdict_entries =
  Class cabal "WDict_entries" [] mempty Nothing
  [
  ]

wdict :: Class
wdict =
  Class cabal "WDict" [] mempty Nothing
  [ Static     (cppclassref_ wdict)         "instance"    [ ] Nothing
  , NonVirtual (cppclasscopy_ wdict_entries) "get_entries"
      [ cppclassref string "word", cppclassref string "pos" ] Nothing 
  ]

vectorfloatref_ = TemplateAppRef t_vector "CFloat" "std::vector<float>"


csentence :: Class
csentence =
  Class cabal "CSentence" [] mempty Nothing
  [ Constructor [ cstring "id" , cstring "ctx_str" ] Nothing
  ]

classes = [string,kb,wdict_entries,wdict,csentence]

toplevelfunctions =
  [ TopLevelFunction bool_ "calculate_kb_ppr" [cppclassref csentence "cs", (vectorfloatref_, "ranks") ] Nothing  

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
            , ("string"       , ([NS "std"          ], [HdrName "string"   ]))
            ]

main :: IO ()
main = do 
  simpleBuilder "HUKB.Binding" headerMap (cabal,cabalattr,classes,toplevelfunctions,templates)
    [ "ukb", "boost_random", "boost_filesystem", "boost_system" ] extraDep
