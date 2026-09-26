//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 31/07/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI
import UniformTypeIdentifiers

//--------------------------------------------------------------------------------------------------

extension UTType {
  nonisolated static let filterSetDocument = UTType (exportedAs: "name.pcmolinaro.pierre.espioncan.filter.set")
}

//--------------------------------------------------------------------------------------------------

struct FilterSetDocument : FileDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static nonisolated let readableContentTypes = [UTType.filterSetDocument]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mData : Data

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor init (_ inFilterSet : FilterSet?) {
    if let filterSet = inFilterSet {
      var s = filterSet.name + "\n"
      for standardFilter in filterSet.standardFilters {
        s += "S \(standardFilter.base.hex3String) \(standardFilter.mask.hex3String) \(standardFilter.name)\n"
      }
      for extendedFilter in filterSet.extendedFilters {
        s += "E \(extendedFilter.base.hex8String) \(extendedFilter.mask.hex8String) \(extendedFilter.name)\n"
      }
      self.mData = s.data (using: .utf8)!
    }else{
      self.mData = Data ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // this initializer loads data that has been saved previously

  init (configuration : ReadConfiguration) throws {
    if let data = configuration.file.regularFileContents {
      self.mData = data
    }else{
      self.mData = Data ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // this will be called when the system wants to write our data to disk

  func fileWrapper (configuration: WriteConfiguration) throws -> FileWrapper {
    return FileWrapper (regularFileWithContents: self.mData)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
