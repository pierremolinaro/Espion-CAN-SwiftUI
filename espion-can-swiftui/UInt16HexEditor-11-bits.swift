//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 28/05/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct UInt16HexEditor_11_bits : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @State private var mHigh : Value0_7
  @State private var mLow : UInt8
  @Binding private var mCurrentValue : UInt16

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (value inValue : Binding<UInt16>) {
    self._mCurrentValue = inValue
    self.mHigh = Value0_7 (rawValue: inValue.wrappedValue >> 8) ?? .v7
    self.mLow = UInt8 (inValue.wrappedValue & 255)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body : some View {
    VStack (spacing: 6) {
      HStack (spacing: 0) {
        Picker ("", selection: self.$mHigh) {
          ForEach (Value0_7.allCases) {
            Text("\($0.rawValue)").tag($0)
          }
        }.pickerStyle(.segmented)
        Spacer ()
      }.padding (0)
      UInt8HexEditor (value: self.$mLow)
    }
    .onChange (of: self.mHigh) { old, new in
      self.mCurrentValue = (self.mHigh.rawValue << 8) | UInt16 (self.mLow)
    }
    .onChange (of: self.mLow) { old, new in
      self.mCurrentValue = (self.mHigh.rawValue << 8) | UInt16 (self.mLow)
    }
    .onChange (of: self.mCurrentValue) { old, new in
      let high = Value0_7 (rawValue: self.mCurrentValue >> 8) ?? .v7
      if self.mHigh != high {
        self.mHigh = high
      }
      let low = UInt8 (self.mCurrentValue & 255)
      if self.mLow != low {
        self.mLow = low
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate enum Value0_7 : UInt16, CaseIterable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  case v0 = 0
  case v1 = 1
  case v2 = 2
  case v3 = 3
  case v4 = 4
  case v5 = 5
  case v6 = 6
  case v7 = 7

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension Value0_7 : Identifiable {
  var id : Self { self }
}

//--------------------------------------------------------------------------------------------------
