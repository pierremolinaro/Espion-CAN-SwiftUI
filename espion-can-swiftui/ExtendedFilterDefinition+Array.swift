//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 31/07/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

extension Array where Element == ExtendedFilterDefinition {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (base inBase : UInt32,
                        mask inMask : UInt32,
                        name inName : String) -> ExtendedFilterID {
    var newId : UInt32 = 0
    var idx = 0
    while idx < self.count {
      if self [idx].id == ExtendedFilterID (newId) {
        newId += 1
        idx = 0
      }else{
        idx += 1
      }
    }
    let id = ExtendedFilterID (newId)
    self.append (.init (id: id, base: inBase, mask: inMask, name: inName))
    self.sort { $0.base < $1.base }
    return id
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func identifierNameForExtendedValue (_ inIdentifier : UInt32) -> String {
    for filter in self {
      if filter.base == (inIdentifier & ~filter.mask) {
        return filter.name
      }
    }
    return "Inconnu 0x\(inIdentifier.hex8SepString)"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
