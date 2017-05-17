g++ -std=c++11 -c globalvar.cc
# ld -r -o combined.o globalvar.o /nix/store/s5k01531964gswsvgj73f7c4835m5p68-ukb-3.0/lib/libukb.a
g++ -std=c++11 -c stub.cc -I $hsenv/lib/ghc-8.0.1/fficxx-runtime-0.3/include -I .cabal-sandbox/lib/x86_64-linux-ghc-8.0.1/HUKB-0.0-JRyMUED2jIT4eYQUHDekO1/include 
cabal exec -- ghc  ukb_wsd_hs.hs globalvar.o stub.o -lboost_random -lukb -lstdc++ 

#cabal exec -- ghc -c ukb_wsd_hs.hs
#cabal exec -- ghc -pgmlg++ ukb_wsd_hs.o globalvar.o -lboost_random
