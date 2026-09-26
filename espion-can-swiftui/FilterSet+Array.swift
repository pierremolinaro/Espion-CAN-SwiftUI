//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 31/07/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

extension Array where Element == FilterSet {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (name inName : String,
                        débitBusAlimentations : CanBusSpeed,
                        débitBusAccessoires : CanBusSpeed,
                        standardFilters inStandardFilters : [StandardFilterDefinition],
                        extendedFilters inExtendedFilters : [ExtendedFilterDefinition]) {
    var newId : UInt32 = 0
    var idx = 0
    while idx < self.count {
      if self [idx].id == FilterSetID (newId) {
        newId += 1
        idx = 0
      }else{
        idx += 1
      }
    }
    self.append (
      .init (
        id: FilterSetID (newId),
        name: inName,
        débitBusAlimentations: débitBusAlimentations,
        débitBusAccessoires: débitBusAccessoires,
        standardFilters: inStandardFilters.sorted { $0.base < $1.base },
        extendedFilters: inExtendedFilters.sorted { $0.base < $1.base }
      )
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
