//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 32/05/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct BaseMask29BitsEditor : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @Binding private var mCurrentBase : UInt32
  @Binding private var mCurrentMask : UInt32
  @State private var mBitArray = [BaseMaskBit] (repeating: BaseMaskBit.bit0, count: 29)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (base inBase : Binding <UInt32>, mask inMask : Binding <UInt32>) {
    self._mCurrentBase = inBase
    self._mCurrentMask = inMask
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body : some View {
    HStack (spacing: 0) {
      VStack (spacing: 4) {
        Text (" ")
        Text ("0")
        Text ("1")
        Text ("X")
        Divider ()
        Text ("Base")
        Text ("Masque")
      }.frame (width: 72)
      VStack (spacing: 4) {
        BaseMaskBitEditor (value: self.$mBitArray [28], title: "28")
        Divider ()
        Text ((self.mCurrentBase >> 28).hexString)
        Text ((self.mCurrentMask >> 28).hexString)
      }
      Spacer ().frame (width: 3)
      self.editor4bits (from: 24)
      Spacer ().frame (width: 6)
      self.editor4bits (from: 20)
      Spacer ().frame (width: 3)
      self.editor4bits (from: 16)
      Spacer ().frame (width: 12)
      self.editor4bits (from: 12)
      Spacer ().frame (width: 3)
      self.editor4bits (from:  8)
      Spacer ().frame (width: 6)
      self.editor4bits (from:  4)
      Spacer ().frame (width: 3)
      self.editor4bits (from:  0)
    }
    .onChange (of: self.mCurrentBase, initial: true) { self.updateBits () }
    .onChange (of: self.mCurrentMask, initial: true) { self.updateBits () }
    .onChange (of: self.mBitArray) { self.updateBaseMask () }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func editor4bits (from index : Int) -> some View {
    VStack (spacing: 4) {
      HStack (spacing: 0) {
        BaseMaskBitEditor (value: self.$mBitArray [index + 3], title: "\(index + 3)")
        BaseMaskBitEditor (value: self.$mBitArray [index + 2], title: "\(index + 2)")
        BaseMaskBitEditor (value: self.$mBitArray [index + 1], title: "\(index + 1)")
        BaseMaskBitEditor (value: self.$mBitArray [index + 0], title: "\(index + 0)")
      }.padding (0)
      Divider ()
      Text (((self.mCurrentBase >> index) & 0xF).hexString)
      Text (((self.mCurrentMask >> index) & 0xF).hexString)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateBits () {
    for i in 0 ..< 29 {
      let b = Self.baseMaskBit (base: self.mCurrentBase, mask: self.mCurrentMask, index: i)
      if self.mBitArray [i] != b {
        self.mBitArray [i] = b
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateBaseMask () {
    var base : UInt32 = 0
    var mask : UInt32 = 0
    for i in 0 ..< 29 {
      switch self.mBitArray [i] {
      case .bit0 : ()
      case .bit1 : base |= 1 << i
      case .bitX : mask |= 1 << i
      }
    }
    if self.mCurrentBase != base {
      self.mCurrentBase = base
    }
    if self.mCurrentMask != mask {
      self.mCurrentMask = mask
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private static func baseMaskBit (base inBase : UInt32,
                                   mask inMask : UInt32,
                                   index inIndex : Int) -> BaseMaskBit {
    if (inMask & (1 << inIndex)) != 0 {
      return .bitX
    }else if (inBase & (1 << inIndex)) != 0 {
      return .bit1
    }else{
      return .bit0
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
