//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 22/03/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

extension Button {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @ViewBuilder func myCancelConfiguration (disabled inDisabled : Bool) -> some View {
     if inDisabled {
       self.disabled (true)
     }else{
//     self.keyboardShortcut (.cancelAction).tint(.red.opacity(0.75)).buttonStyle(.borderedProminent)
       self
       .keyboardShortcut (.cancelAction)
//     .background (.clear)
//     .foregroundColor (.red)
       .overlay (RoundedRectangle (cornerRadius: 6, style: .continuous).stroke (.red, lineWidth: 2.0))
     }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
