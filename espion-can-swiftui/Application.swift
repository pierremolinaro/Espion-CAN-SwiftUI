//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 07/10/2025.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

@main struct Application : App {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body: some Scene {
    WindowGroup {
      MainView ()
      .frame (minWidth: 480, minHeight: 280)
      .windowDismissBehavior (.disabled)
    }
    .commands {
      CommandGroup (replacing: .newItem) {
      // Leave this blank to remove the new window functionality
      // Or add the element below to replace the New Window command.
//          Button("New Command + N Command") {
//              objectCaptureCoordinator.showModal = true
//          }
//          .keyboardShortcut("N", modifiers: [.command])
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
