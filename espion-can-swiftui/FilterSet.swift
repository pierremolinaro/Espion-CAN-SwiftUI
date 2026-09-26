//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 31/07/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct FilterSet : Identifiable, Equatable, Codable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let id : FilterSetID

  var name : String
  var débitBusAlimentations : CanBusSpeed
  var débitBusAccessoires : CanBusSpeed
  var standardFilters : [StandardFilterDefinition]
  var extendedFilters : [ExtendedFilterDefinition]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
