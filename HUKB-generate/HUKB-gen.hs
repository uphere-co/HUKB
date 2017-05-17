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

classes = [string,kb]

toplevelfunctions = []


templates = []

headerMap = [ ("Kb", ([NS "ukb", NS "std"], [HdrName "kbGraph.h"]))
            , ("string", ([NS "std"], [HdrName "string"]))
            ]
{- 
[ ( "EngineWrapper", ([NS "util"], [HdrName "enginewrapper.h"]))
            , ( "json_t"         , ([NS "util"], [HdrName "utils/json.h", HdrName "enginewrapper.h" ]))
            ]
-}

main :: IO ()
main = do 
  simpleBuilder "HUKB.Binding" headerMap (cabal,cabalattr,classes,toplevelfunctions,templates)
    [ ] extraDep
