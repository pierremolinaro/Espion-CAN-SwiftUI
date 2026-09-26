#include <iostream>

#include "encoder.h"

//------------------------------------------------------------------------------

void encodeCmd (std::vector <uint8_t> & ioBuffer,
                const uint8_t inCommand) { // Bit 7 et 6 ignorés
  ioBuffer.push_back (inCommand | 0xC0) ;
}

//------------------------------------------------------------------------------

void encodeU32 (std::vector <uint8_t> & ioBuffer,
                const uint32_t inValue) {
  ioBuffer.push_back (uint8_t ((inValue & 0x0F) | 0x80)) ;
  uint32_t v = inValue >> 4 ;
  while (v > 0) {
    ioBuffer.push_back (uint8_t (v & 0x7F)) ;
    v >>= 7 ;
  }
}

//------------------------------------------------------------------------------

void encodeU64 (std::vector <uint8_t> & ioBuffer,
                const uint64_t inValue) {
  ioBuffer.push_back (uint8_t ((inValue & 0x0F) | 0x80)) ;
  uint64_t v = inValue >> 4 ;
  while (v > 0) {
    ioBuffer.push_back (uint8_t (v & 0x7F)) ;
    v >>= 7 ;
  }
}

//------------------------------------------------------------------------------

void encodeS32 (std::vector <uint8_t> & ioBuffer,
                const int32_t inValue) {
  if (inValue >= 0) {
    encodeU32 (ioBuffer, uint32_t (inValue)) ;
  }else{
    uint32_t v = ~ uint32_t (inValue) ;
    ioBuffer.push_back (uint8_t ((v & 0x0F) | 0x90)) ;
    v >>= 4 ;
    while (v > 0) {
      ioBuffer.push_back (uint8_t (v & 0x7F)) ;
      v >>= 7 ;
    }
  }
}

//------------------------------------------------------------------------------
//                 UTF8 encoding
//
// 0000 0000  0000 0000  0xxx xxxx -> 0xxx xxxx
// 0000 0000  0000 0yyy  xxxx xxxx -> 110y yyxx  10xx xxxx
// 0000 0000  zzzz yyyy  xxxx xxxx -> 1110 zzzz  10yy yyxx  10xx xxxx
// 000u uuuu  zzzz yyyy  xxxx xxxx -> 1111 0uuu  10uu zzzz  10yy yyxx  10xx xxxx
//--------------------------------------------------------------------------------------------------

static uint32_t utf32CharacterForPointer (const uint8_t * inDataString,
                                          size_t & ioIndex,
                                          const size_t inLength,
                                          bool & ioOK) {
  uint32_t result = 0 ;
  uint32_t c = inDataString [ioIndex] ;
  ioIndex += 1 ;
  ioOK = true ;
  if ((c & 0x80) == 0) {
    result = c ;
  }else if ((c & 0xE0) == 0xC0) {
    result = c & 0x1F ;
    result <<= 6 ;
    c = inDataString [ioIndex] ;
    ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
    if (ioOK) {
      ioIndex += 1 ;
      result |= c & 0x3F ;
    }
  }else if ((c & 0xF0) == 0xE0) {
    result = c & 0x0F ;
    result <<= 12 ;
    c = inDataString [ioIndex] ;
    ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
    if (ioOK) {
      ioIndex += 1 ;
      result |= (c & 0x3F) << 6 ;
      c = inDataString [ioIndex] ;
      if (ioOK) {
        ioOK &= ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
        ioIndex += 1 ;
        result |= c & 0x3F ;
      }
    }
  }else if ((c & 0xF8) == 0xF0) {
    result = (c & 0x07) << 18 ;
    c = inDataString [ioIndex] ;
    ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
    if (ioOK) {
      ioIndex += 1 ;
      result |= (c & 0x3F) << 12 ;
      c = inDataString [ioIndex] ;
      ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
      if (ioOK) {
        ioIndex += 1 ;
        result |= (c & 0x3F) << 6 ;
        c = inDataString [ioIndex] ;
        ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
        if (ioOK) {
          ioIndex += 1 ;
          result |= c & 0x3F ;
        }
      }
    }
  }else{
    ioOK = false ;
  }
  if (!ioOK) {
    result = 0x0000FFFD ; // UNICODE_REPLACEMENT_CHARACTER
  }
  return result ;
}

//------------------------------------------------------------------------------

void encodeStr (std::vector <uint8_t> & ioBuffer,
                const std::string inUTF8String) {
  ioBuffer.push_back (0xA0) ;
  const uint8_t * cString = (const uint8_t *) inUTF8String.c_str () ;
  const size_t utf8ByteCount = strlen ((const char *) cString) ;
  size_t utf8Index = 0 ;
  bool ok = true ;
  while ((utf8Index < utf8ByteCount) && ok) {
    const uint32_t unicodeChar = utf32CharacterForPointer (cString, utf8Index, utf8ByteCount, ok) ;
    std::cout << "    encoded utf32 : 0x" << std::hex << unicodeChar << std::dec << "\n" ;
    if (ok) {
      if ((unicodeChar >= 0x10) && (unicodeChar <= 0x1F)) { // control 0001 xxxx
        ioBuffer.push_back (uint8_t (unicodeChar)) ;
        ioBuffer.push_back (0x41) ;
      }else if (unicodeChar <= 0x7F) { // ASCII
        ioBuffer.push_back (uint8_t (unicodeChar)) ;
      }else if (unicodeChar <= 0x3FF) {
        ioBuffer.push_back (uint8_t (unicodeChar & 0x0F) | 0x10) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 4) | 0x40) ;
      }else if (unicodeChar <= 0xFFFF) {
        ioBuffer.push_back (uint8_t (unicodeChar & 0x0F) | 0x10) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 4) & 0x3F) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 10) | 0x40) ;
      }else{
        ioBuffer.push_back (uint8_t (unicodeChar & 0x0F) | 0x10) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 4) & 0x3F) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 10) & 0x3F) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 16) | 0x40) ;
      }
    }
  }
}

//------------------------------------------------------------------------------
