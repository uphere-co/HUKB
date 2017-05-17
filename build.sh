g++ -std=c++11 -c globalvar.cc
cabal exec -- ghc ukb_wsd_hs.hs globalvar.o

#cabal exec -- ghc -c ukb_wsd_hs.hs
#cabal exec -- ghc -pgmlg++ ukb_wsd_hs.o globalvar.o
