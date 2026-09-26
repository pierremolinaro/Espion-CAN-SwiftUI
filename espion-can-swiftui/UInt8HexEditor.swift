//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 28/05/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct UInt8HexEditor : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @State private var mHigh : Hex4
  @State private var mLow : Hex4
  @Binding private var mCurrentValue : UInt8

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (value inValue : Binding<UInt8>) {
    self._mCurrentValue = inValue
    self.mHigh = Hex4 (rawValue: inValue.wrappedValue >> 4)!
    self.mLow = Hex4 (rawValue: inValue.wrappedValue & 0x0F)!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body : some View {
    VStack (spacing: 1) {
      Picker ("", selection: self.$mHigh) {
        ForEach (Hex4.allCases) {
          Text($0.hexString).tag($0)
        }
      }.pickerStyle(.segmented)
      Picker ("", selection: self.$mLow) {
        ForEach (Hex4.allCases) {
          Text($0.hexString).tag($0)
        }
      }.pickerStyle(.segmented)
    }
    .onChange (of: self.mHigh) { old, new in
      self.mCurrentValue = (self.mHigh.rawValue << 4) | self.mLow.rawValue
    }
    .onChange (of: self.mLow) { old, new in
      self.mCurrentValue = (self.mHigh.rawValue << 4) | self.mLow.rawValue
    }
    .onChange (of: self.mCurrentValue) { old, new in
      let high = Hex4 (rawValue: self.mCurrentValue >> 4)!
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
