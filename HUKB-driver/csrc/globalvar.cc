#include <iostream>
#include <vector>
//
#include <globalVars.h>
#include <csentence.h>

extern "C" {
    void set_global( char* c_str );
    void* get_cout( );
    void* get_vec_cword_from_csentence( void* sent0 ); 
}

using namespace ukb;

void set_global( char* c_str )  {
    std::string str{c_str};
    glVars::dict::text_fname = str; 
}

void* get_cout( ) {
    return &(std::cout); 
}

void* get_vec_cword_from_csentence( void* sent0 )
{
    CSentence* sent;
    sent = (CSentence*)sent0;
    std::vector<CWord>* output = new std::vector<CWord>();
    std::copy(sent->ubegin(),sent->uend(),std::back_inserter(*output));
    return output;
}
