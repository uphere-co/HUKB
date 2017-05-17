#include <globalVars.h>

extern "C" {
    void set_global( char* c_str );
}

using namespace ukb;

void set_global( char* c_str )  {
    std::string str{c_str};
    glVars::dict::text_fname = str; 
}
