//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 28/05/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct UInt8HexEditor5Bits : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @State private var mHigh : Bool
  @State private var mLow : Hex4
  @Binding private var mCurrentValue : UInt8

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (value inValue : Binding<UInt8>) {
    self._mCurrentValue = inValue
    self.mHigh = (inValue.wrappedValue >> 4) != 0
    self.mLow = Hex4 (rawValue: inValue.wrappedValue & 0x0F)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body : some View {
    VStack (spacing: 1) {
      HStack (spacing: 0) {
        Picker ("", selection: self.$mHigh) {
          Text("0").tag (false)
          Text("1").tag (true)
        }.pickerStyle(.segmented)
        Spacer ()
      }
      Picker ("", selection: self.$mLow) {
        ForEach (Hex4.allCases) {
          Text($0.hexString).tag($0)
        }
      }.pickerStyle(.segmented)
    }
    .onChange (of: self.mHigh) { old, new in
      self.mCurrentValue = (self.mHigh ? 0x10 : 0) | self.mLow.rawValue
    }
    .onChange (of: self.mLow) { old, new in
      self.mCurrentValue = (self.mHigh ? 0x10 : 0) | self.mLow.rawValue
    }
    .onChange (of: self.mCurrentValue) { old, new in
      let high = (self.mCurrentValue >> 4) != 0
      if self.mHigh != high {
        self.mHigh = high
      }
      let low = Hex4 (rawValue: self.mCurrentValue & 0x0F)!
      if self.mLow != low {
        self.mLow = low
      }
    }.controlSize (.small)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
