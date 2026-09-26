//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 32/05/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

enum BaseMaskBit : UInt8, CaseIterable {
  case bit0
  case bit1
  case bitX

  var string : String {
    switch self {
    case .bit0 : return "0"
    case .bit1 : return "1"
    case .bitX : return "X"
    }
  }
}

//--------------------------------------------------------------------------------------------------

extension BaseMaskBit : Identifiable {
  var id : Self { self }
}

//--------------------------------------------------------------------------------------------------

struct BaseMaskBitEditor : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @Binding private var mCurrentValue : BaseMaskBit
  private let mTitle : String

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (value inValue : Binding<BaseMaskBit>, title inTitle : String) {
    self._mCurrentValue = inValue
    self.mTitle = inTitle
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body : some View {
    VStack (spacing: 1) {
      Text (self.mTitle)
      Picker ("", selection: self.$mCurrentValue) {
        ForEach (BaseMaskBit.allCases) {
          Text ("").tag ($0)
        }
      }.pickerStyle (.radioGroup).labelsHidden()
    }.padding (0).controlSize (.small).frame (width: 20)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
