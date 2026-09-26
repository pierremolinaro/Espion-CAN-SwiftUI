#pragma once

//------------------------------------------------------------------------------

#include <vector>

//------------------------------------------------------------------------------

void encodeU32 (std::vector <uint8_t> & ioBuffer,
                const uint32_t inValue) ;

//------------------------------------------------------------------------------

void encodeU64 (std::vector <uint8_t> & ioBuffer,
                const uint64_t inValue) ;

//------------------------------------------------------------------------------

void encodeS32 (std::vector <uint8_t> & ioBuffer,
                const int32_t inValue) ;

//------------------------------------------------------------------------------

void encodeStr (std::vector <uint8_t> & ioBuffer,
                const std::string inUTF8String) ;

//------------------------------------------------------------------------------

void encodeCmd (std::vector <uint8_t> & ioBuffer,
                const uint8_t inCommand) ; // Bit 7 et 6 ignorés

//------------------------------------------------------------------------------

