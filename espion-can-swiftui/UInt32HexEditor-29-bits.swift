//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 28/05/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct UInt32HexEditor_29_bits : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @State private var mUpper : UInt8
  @State private var mHigh : UInt8
  @State private var mLow : UInt16
  @Binding private var mCurrentValue : UInt32

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (value inValue : Binding<UInt32>) {
    self._mCurrentValue = inValue
    self.mUpper = UInt8 (inValue.wrappedValue >> 24)
    self.mHigh = UInt8 ((inValue.wrappedValue >> 16) & 255)
    self.mLow = UInt16 (inValue.wrappedValue & 0xFFFF)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body : some View {
    VStack (spacing: 12) {
      UInt8HexEditor5Bits (value: self.$mUpper)
      UInt8HexEditor (value: self.$mHigh)
      UInt16HexEditor (value: self.$mLow)
    }
    .onChange (of: self.mUpper) { old, new in
      self.mCurrentValue = (UInt32 (self.mUpper) << 24) | (UInt32 (self.mHigh) << 16) | UInt32 (self.mLow)
    }
    .onChange (of: self.mHigh) { old, new in
      self.mCurrentValue = (UInt32 (self.mUpper) << 24) | (UInt32 (self.mHigh) << 16) | UInt32 (self.mLow)
    }
    .onChange (of: self.mLow) { old, new in
      self.mCurrentValue = (UInt32 (self.mUpper) << 24) | (UInt32 (self.mHigh) << 16) | UInt32 (self.mLow)
    }
    .onChange (of: self.mCurrentValue) { old, new in
      let upper = UInt8 (self.mCurrentValue >> 24)
      if self.mUpper != upper {
        self.mUpper = upper
      }
      let high = UInt8 ((self.mCurrentValue >> 16) & 255)
      if self.mHigh != high {
        self.mHigh = high
      }
      let low = UInt16 (self.mCurrentValue & 0xFFFF)
      if self.mLow != low {
        self.mLow = low
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
