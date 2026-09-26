//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 31/07/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct StandardFilterDefinition : Identifiable, Equatable, Codable {

  let id : StandardFilterID

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var base : UInt16
  var mask : UInt16
  var name : String

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var count = 0
  var isDisplayed : Bool = true

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func accept (identifier inIdentifier : UInt16) -> Bool {
    return self.base == (inIdentifier & ~self.mask)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var displayString : String {
    var s = "\(self.name), 0x\(self.base.hex3String)"
    if self.mask != 0 {
      s += ", masque 0x\(self.mask.hex3String)"
    }
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension Binding where Value == StandardFilterDefinition {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @ViewBuilder func standardFilterView () -> some View {
    HStack {
      Toggle ("\(self.wrappedValue.count) : \(self.wrappedValue.displayString)", isOn: self.isDisplayed)
      .disabled (self.wrappedValue.count == 0)
      Spacer ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
