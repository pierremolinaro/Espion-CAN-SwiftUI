#include <iostream>

//------------------------------------------------------------------------------

#include "decoder.h"
#include "encoder.h"

//------------------------------------------------------------------------------

int main (int argc, const char * argv []) {
  std::vector <uint8_t> data ;
  encodeU32 (data, 12345678) ;
  encodeU32 (data, 87654321) ;
  encodeS32 (data, -87654321) ;
  encodeStr (data, "Hello") ;
  encodeStr (data, "éèôœ") ;
  encodeStr (data, "�🪒") ;
  encodeCmd (data, 0x33) ;
//--- Decodage
  std::cout << "Data:" ;
  for (uint8_t byte : data) {
    std::cout << " 0x" << std::hex << uint32_t (byte) << std::dec ; ;
  }
  std::cout << "\n" ;
  for (uint8_t byte : data) {
    enterByteInDecoder (byte) ;
  }
  return EXIT_SUCCESS;
}
