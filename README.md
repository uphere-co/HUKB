How to test

```
$ nix-shell shell.nix
$ runhaskell HUKB-generate/HUKB-gen.hs 
$ cabal sandbox init
$ cabal sandbox add-source HUKB
$ cabal install HUKB
$ cabal exec -- ghc test.hs
$ ./test
```
