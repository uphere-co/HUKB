{ stdenv, fetchgit, fetchurl, boost }:

let ukbsrc = fetchgit {
      url = "https://github.com/uphere-co/ukb.git";
      rev = "356f24b1155f97b37748911a421827fe38fefe1c";
             # "28b0657fc17b84d83a8eaca0e6e9eb030df110c9"
      sha256 = "10lh3xv9ck98vac6ba6251xsf4ny9v6lic17rgwmw4qqwzcc1b7h";
             # "03kdppvm01w8yfjrgzw3v6y4q5bkdpnihbn5vhl1cpkzai1cxjks"
    };
    
    lkbsrc = fetchurl {
      url = "http://ixa2.si.ehu.es/ukb/lkb_sources.tar.bz2";
      sha256 = "16xmn1ninz23aysx716ngmwn97h2z3v2zkbbkvgm1fz4brhmqfly";
    };
in 

stdenv.mkDerivation {
  name = "ukb-3.0";
  src = ukbsrc + "/src";
  buildInputs = [ boost ];
  enableParallelBuilding = true;
  configureFlags = [ 
                     "--with-boost-include=${boost.dev}/include"
                     "--with-boost-lib=${boost}/lib"
                   ];
  postInstall = ''
    tar -xjvf ${lkbsrc}
    $out/bin/compile_kb -o wn30.bin lkb_sources/30/wnet30_rels.txt
    mkdir -p $out/share/data
    mkdir -p $out/share/example
    cp wn30.bin $out/share/data/wn30.bin
    cp lkb_sources/30/wnet30_dict.txt $out/share/data/wnet30_dict.txt
    cat > $out/share/example/context.txt << EOF
    ctx_01
    man#n#w1#1 kill#v#w2#1 cat#n#w3#1 hammer#n#w4#1
    EOF
  '';

  meta = {
  };
}

