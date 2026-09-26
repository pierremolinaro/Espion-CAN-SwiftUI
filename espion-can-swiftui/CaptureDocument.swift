//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 11/10/2025.
//--------------------------------------------------------------------------------------------------

import SwiftUI
import UniformTypeIdentifiers

//--------------------------------------------------------------------------------------------------

extension UTType {
  nonisolated static let captureDocument = UTType (exportedAs: "name.pcmolinaro.pierre.espioncan.capture")
}

//--------------------------------------------------------------------------------------------------

struct CaptureDocument : FileDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static nonisolated let readableContentTypes = [UTType.captureDocument]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // by default our document is empty
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mText : String

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inFrameArray : [CANFrame]) {
    self.mText = "time\u{9}identifier\u{9}data\u{9}length\u{9}extended\u{9}remote\u{9}network\n"
    for frame in inFrameArray {
      self.mText += frame.stringForDocumentSaving + "\n"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // this initializer loads data that has been saved previously

  init (configuration : ReadConfiguration) throws {
    if let data = configuration.file.regularFileContents {
      self.mText = String (decoding: data, as: UTF8.self)
    }else{
      self.mText = ""
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // this will be called when the system wants to write our data to disk

  func fileWrapper (configuration: WriteConfiguration) throws -> FileWrapper {
    let data = Data (self.mText.utf8)
    return FileWrapper (regularFileWithContents: data)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
