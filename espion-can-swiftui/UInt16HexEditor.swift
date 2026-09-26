//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 28/05/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct UInt16HexEditor : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @State private var mHigh : UInt8
  @State private var mLow : UInt8
  @Binding private var mCurrentValue : UInt16

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (value inValue : Binding<UInt16>) {
    self._mCurrentValue = inValue
    self.mHigh = UInt8 (inValue.wrappedValue >> 8)
    self.mLow = UInt8 (inValue.wrappedValue & 255)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body : some View {
    VStack (spacing: 6) {
      UInt8HexEditor (value: self.$mHigh)
      UInt8HexEditor (value: self.$mLow)
    }
    .onChange (of: self.mHigh) { old, new in
      self.mCurrentValue = (UInt16 (self.mHigh) << 8) | UInt16 (self.mLow)
    }
    .onChange (of: self.mLow) { old, new in
      self.mCurrentValue = (UInt16 (self.mHigh) << 8) | UInt16 (self.mLow)
    }
    .onChange (of: self.mCurrentValue) { old, new in
      let high = UInt8 (self.mCurrentValue >> 8)
      if self.mHigh != high {
        self.mHigh = high
      }
      let low = UInt8 (self.mCurrentValue & 255)
      if self.mLow != low {
        self.mLow = low
      }
    }.controlSize (.small)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
