#include <iostream>

//------------------------------------------------------------------------------

#include "decoder.h"

//------------------------------------------------------------------------------

enum class ByteFormat {
  extension,
  beginUnsigned,
  beginSigned,
  beginString,
  command,
  undefined
} ;

//------------------------------------------------------------------------------

ByteFormat formatForByte (const uint8_t inByte) {
  ByteFormat result = ByteFormat::undefined ;
  if ((inByte & 0x80) == 0) {
    result = ByteFormat::extension ;
  }else if ((inByte & 0xF0) == 0x80) {
    result = ByteFormat::beginUnsigned ;
  }else if ((inByte & 0xF0) == 0x90) {
    result = ByteFormat::beginSigned ;
  }else if (inByte == 0xA0) {
    result = ByteFormat::beginString ;
  }else if ((inByte & 0xC0) == 0xC0) {
    result = ByteFormat::command ;
  }else{
    std::cout << "  Undefined byte: 0x" << std::hex << uint32_t (inByte) << std::dec << "\n" ;
  }
  return result ;
}

//------------------------------------------------------------------------------

enum class DecoderState {
  idle,
  decodingUnsigned,
  decodingSigned,
  decodingString,
  error
} ;

//------------------------------------------------------------------------------

static DecoderState gDecoderState = DecoderState::idle ;
static uint32_t gDecodingU32Value = 0 ;
static uint32_t gDecodingU32Shift = 0 ;
static std::vector <uint8_t> gDecodingString ;

//------------------------------------------------------------------------------

static std::string decodeStringFromByteArray (void) {
  std::string result ;
  uint32_t multiByteShift = 0 ;
  uint32_t utf32Value = 0 ;
  for (uint8_t byte : gDecodingString) {
    if (multiByteShift > 0) {
      if ((byte & 0x40) == 0) {
        utf32Value |= uint32_t (byte & 0x3F) << multiByteShift ;
        multiByteShift += 6 ;
      }else{ // End of multi byte
        utf32Value |= uint32_t (byte & 0x3F) << multiByteShift ;
        std::cout << "    decoded utf32 : 0x" << std::hex << utf32Value << std::dec << "\n" ;
        if (utf32Value <= 0x7F) {
          result.push_back (char (utf32Value)) ;
        }else if (utf32Value <= 0x7FF) {
          result.push_back (char (0xC0 | (utf32Value >> 6))) ;
          result.push_back (char (0x80 | (utf32Value & 0x3F))) ;
        }else if (utf32Value <= 0xFFFF) {
          result.push_back (char (0xE0 | (utf32Value >> 12))) ;
          result.push_back (char (0x80 | ((utf32Value >> 6) & 0x1F))) ;
          result.push_back (char (0x80 | (utf32Value & 0x1F))) ;
        }else{
          result.push_back (char (0xF0 | (utf32Value >> 18))) ;
          result.push_back (char (0x80 | ((utf32Value >> 12) & 0x1F))) ;
          result.push_back (char (0x80 | ((utf32Value >> 6) & 0x1F))) ;
          result.push_back (char (0x80 | (utf32Value & 0x1F))) ;
        }
        utf32Value = 0 ;
        multiByteShift = 0 ;
      }
    }else if ((byte >= 0x10) && (byte <= 0x1F)) { // Start multibyte
      utf32Value = uint32_t (byte & 0x0F) ;
      multiByteShift = 4 ;
    }else{
      result.push_back (char (byte)) ;
    }
  }
  return result ;
}

//------------------------------------------------------------------------------

static void closeCurrentValueDecoding (void) {
  switch (gDecoderState) {
  case DecoderState::decodingUnsigned :
    std::cout << "  Decoded U32: " << gDecodingU32Value << "\n" ;
    gDecoderState = DecoderState::idle ;
    break ;
  case DecoderState::decodingSigned :
    { const int32_t v = int32_t (~gDecodingU32Value) ;
      std::cout << "  Decoded S32: " << v << "\n" ;
      gDecoderState = DecoderState::idle ;
    } break ;
  case DecoderState::decodingString :
    { const std::string s = decodeStringFromByteArray () ;
      std::cout << "  Decoded Str: \"" << s << "\"\n" ;
      gDecoderState = DecoderState::idle ;
    } break ;
  case DecoderState::idle :
  case DecoderState::error :
    break ;
  }
}

//------------------------------------------------------------------------------

void enterByteInDecoder (const uint8_t inByte) {
//  std::cout << "Byte 0x" << std::hex << uint32_t (inByte) << std::dec << "\n" ;
  const ByteFormat f = formatForByte (inByte) ;
  switch (f) {
  case ByteFormat::extension :
    switch (gDecoderState) {
    case DecoderState::decodingUnsigned :
    case DecoderState::decodingSigned :
      gDecodingU32Value |= uint32_t (inByte & 0x7F) << gDecodingU32Shift ;
      gDecodingU32Shift += 7 ;
      break ;
    case DecoderState::decodingString :
      gDecodingString.push_back (inByte) ;
      break ;
    case DecoderState::idle :
    case DecoderState::error :
      break ;
    }
    break ;
  case ByteFormat::beginUnsigned :
    closeCurrentValueDecoding () ;
    gDecodingU32Value = uint32_t (inByte & 0x0F) ;
    gDecodingU32Shift = 4 ;
    gDecoderState = DecoderState::decodingUnsigned ;
    break ;
  case ByteFormat::beginSigned :
    closeCurrentValueDecoding () ;
    gDecodingU32Value = uint32_t (inByte & 0x0F) ;
    gDecodingU32Shift = 4 ;
    gDecoderState = DecoderState::decodingSigned ;
    break ;
  case ByteFormat::beginString :
    closeCurrentValueDecoding () ;
    gDecodingString.clear () ;
    gDecoderState = DecoderState::decodingString ;
    break ;
  case ByteFormat::command :
    closeCurrentValueDecoding () ;
    std::cout << "  Decoded Cmd: 0x" << std::hex << uint32_t (inByte & 0x3F) <<std::dec << "\n" ;
    break ;
  case ByteFormat::undefined :
    break ;
  }
}

//------------------------------------------------------------------------------
