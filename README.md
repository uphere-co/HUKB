How to test

```
$ nix-shell shell.nix
$ runhaskell HUKB-generate/HUKB-gen.hs 
$ cabal sandbox init
$ cabal sandbox add-source HUKB
$ cabal install HUKB
$ cabal exec -- ghc ukb_wsd_hs.hs
$ ./ukb_wsd_hs -K wn30.bin -D wnet30_dict.txt
```
