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


classes = [string,kb,wdict_entries,wdict]

toplevelfunctions = []


templates = []

headerMap = [ ("Kb"           , ([NS "ukb", NS "std"], [HdrName "kbGraph.h"]))
            , ("WDict_entries", ([NS "ukb", NS "std"], [HdrName "wdict.h"  ]))
            , ("WDict"        , ([NS "ukb", NS "std"], [HdrName "wdict.h"  ]))
            , ("string"       , ([NS "std"          ], [HdrName "string"   ]))
            ]

main :: IO ()
main = do 
  simpleBuilder "HUKB.Binding" headerMap (cabal,cabalattr,classes,toplevelfunctions,templates)
    [ "ukb" ] extraDep
