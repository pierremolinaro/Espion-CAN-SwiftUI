//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 10/10/2025.
//--------------------------------------------------------------------------------------------------

import SwiftUI
import PicoConnection

//--------------------------------------------------------------------------------------------------
// Format d'une commande contenant une trame CAN
// commande : 0xC1
//   Premier opérande : date de réception (en µs)
//   Deuxième opérande : descripteur de trame
//       bit 0 à 3 : nombre d'octets de données
//       bit 4 : 0 -> standard, 1 : extended
//       bit 5 : 0 -> réseau CAN Accessoires, 1 : réseau CAN Alimentations
//       bit 6 : 0 -> trame_données, 1 : trame_remote
//   Troisième opérande : identificateur
//   Quatrième opérande : (si nombre d'octets de données > 0) et trame_données
//       bit  0 à  7 : data 0
//       bit  8 à 15 : data 1
//       bit 16 à 23 : data 2
//       bit 24 à 31 : data 3
//       bit 32 à 39 : data 4
//       bit 40 à 47 : data 5
//       bit 48 à 55 : data 6
//       bit 56 à 63 : data 7
//--------------------------------------------------------------------------------------------------

nonisolated struct CANFrame : Identifiable, Equatable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let id = UUID ()

  var dateString : String {
    var s = (self.date / 1000).displayString + " ms"
    let µs = self.date % 1000
    if µs > 0 {
      s += " \(µs) µs"
    }
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var identifierString : String {
    var s = "0x"
    if self.extended {
      s += self.identifier.hex8SepString
    }else{
      s += UInt16 (self.identifier).hex3String
    }
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func identifierString (_ inStandardFilters : [StandardFilterDefinition],
                         _ inExtendedFilters : [ExtendedFilterDefinition],
                         _ inDecoding : Bool) -> String {
    if !inDecoding {
     return self.identifierString
    }else if self.extended {
      return inExtendedFilters.identifierNameForExtendedValue (self.identifier)
    }else{
      return inStandardFilters.identifierNameForStandardValue (UInt16 (self.identifier))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  var formatString : String {
//    (self.remote ? "R" : "") + (self.extended ? "X" : "S")
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var networkString : String {
    switch self.network {
    case .alimentations : return "Alim"
    case .accessoires : return "Acc"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var dataString : String {
    if self.remote {
      return "remote: \(self.length) octets"
    }else{
      var s = ""
      for i in 0 ..< Int (self.length) {
        if i > 0 { s += " " }
        s += "0x" + String ((self.data >> (8 * i)) & 0xFF, radix: 16).uppercased ()
      }
      return s
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum Network : Int {
    case accessoires = 0
    case alimentations = 1
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let date : UInt64
  let identifier : UInt32
  let data : UInt64
  let length : UInt8
  let extended : Bool
  let remote : Bool
  let network : Network

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var filterIndex : Int? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor init (_ inCommand : PicoConnection <WiFiSendCode, WiFiReceiveCode>.Command) {
    self.date = inCommand.parameters [0].u64!
    self.length = UInt8 (inCommand.parameters [1].u64! & 0x0F)
    self.extended = (inCommand.parameters [1].u64! & 0x10) != 0
    self.network = ((inCommand.parameters [1].u64! & 0x20) != 0) ? .alimentations : .accessoires
    self.remote = (inCommand.parameters [1].u64! & 0x40) != 0
    self.identifier = UInt32 (inCommand.parameters [2].u64!)
    if self.length > 0, !self.remote {
      self.data = inCommand.parameters [3].u64!
    }else{
      self.data = 0
    }
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  nonisolated var stringForDocumentSaving : String {
    var s = "\(self.date)"
    s += "\u{9}\(self.identifier)"
    s += "\u{9}\(self.data)"
    s += "\u{9}\(self.length)"
    s += "\u{9}\(self.extended ? "1" : "0")"
    s += "\u{9}\(self.remote ? "1" : "0")"
    s += "\u{9}\(self.network.rawValue)"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init? (stringSavedInDocument inLine : String) {
    let scanner = Scanner (string: inLine)
    scanner.charactersToBeSkipped?.insert ("\u{9}")
    if let v = scanner.scanInt () {
      self.date = UInt64 (v)
    }else{
      return nil
    }
    if let v = scanner.scanInt () {
      self.identifier = UInt32 (v)
    }else{
      return nil
    }
    if let v = scanner.scanInt () {
      self.data = UInt64 (v)
    }else{
      return nil
    }
    if let v = scanner.scanInt () {
      self.length = UInt8 (v)
    }else{
      return nil
    }
    if let v = scanner.scanInt () {
      self.extended = v != 0
    }else{
      return nil
    }
    if let v = scanner.scanInt () {
      self.remote = v != 0
    }else{
      return nil
    }
    if let v = scanner.scanInt () {
      self.network = (v != 0) ? .alimentations : .accessoires
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
