//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 31/07/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct ExtendedFilterDefinition : Identifiable, Equatable, Codable {

  let id : ExtendedFilterID

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var base : UInt32
  var mask : UInt32
  var name : String

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var count = 0
  var isDisplayed : Bool = true

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func accept (identifier inIdentifier : UInt32) -> Bool {
    return self.base == (inIdentifier & ~self.mask)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var displayString : String {
    var s = "\(self.name), 0x\((self.base >> 16).hex4String)_\(self.base.hex4String)"
    if self.mask != 0 {
      s += ", masque 0x\((self.mask >> 16).hex4String)_\(self.mask.hex4String)"
    }
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension Binding where Value == ExtendedFilterDefinition {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @ViewBuilder func extendedFilterView () -> some View {
    HStack {
      Toggle ("\(self.wrappedValue.count) : \(self.wrappedValue.displayString)", isOn: self.isDisplayed)
      .disabled (self.wrappedValue.count == 0)
      Spacer ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
