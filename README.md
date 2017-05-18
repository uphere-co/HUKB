How to test

```
$ nix-shell shell.nix
$ runhaskell HUKB-generate/HUKB-gen.hs 
$ cabal sandbox init
$ cabal sandbox add-source HUKB
$ cabal install HUKB
$ ./build.sh 
$ ./ukb_wsd_hs -K wn30.bin -D wnet30_dict.txt
```
