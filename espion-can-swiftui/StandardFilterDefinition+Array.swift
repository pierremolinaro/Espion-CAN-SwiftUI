//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 31/07/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

extension Array where Element == StandardFilterDefinition {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (base inBase : UInt16,
                        mask inMask : UInt16,
                        name inName : String) -> StandardFilterID {
    var newId : UInt32 = 0
    var idx = 0
    while idx < self.count {
      if self [idx].id == StandardFilterID (newId) {
        newId += 1
        idx = 0
      }else{
        idx += 1
      }
    }
    let id = StandardFilterID (newId)
    self.append (.init (id: id, base: inBase, mask: inMask, name: inName))
    self.sort { $0.base < $1.base }
    return id
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func identifierNameForStandardValue (_ inIdentifier : UInt16) -> String {
    for filter in self {
      if filter.base == (inIdentifier & ~filter.mask) {
        return filter.name
      }
    }
    return "Inconnu 0x\(inIdentifier.hex3String)"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
