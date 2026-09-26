//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 07/10/2025.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

struct IPAddressEditor : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @Binding private var mIPAddress : UInt32
  @State private var mIP3 : UInt8 = 0
  @State private var mIP2 : UInt8 = 0
  @State private var mIP1 : UInt8 = 0
  @State private var mIP0 : UInt8 = 0

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (IPAddressBinding inIPAddressBinding : Binding <UInt32>) {
    self._mIPAddress = inIPAddressBinding
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body : some View {
    HStack {
      TextField ("", value: self.$mIP3, format: .number).frame (width: 40).multilineTextAlignment(.center)
      Text (".")
      TextField ("", value: self.$mIP2, format: .number).frame (width: 40).multilineTextAlignment(.center)
      Text (".")
      TextField ("", value: self.$mIP1, format: .number).frame (width: 40).multilineTextAlignment(.center)
      Text (".")
      TextField ("", value: self.$mIP0, format: .number).frame (width: 40).multilineTextAlignment(.center)
    }
    .onChange (of: self.mIPAddress, initial: true) {
      self.mIP3 = UInt8 (self.mIPAddress >> 24)
      self.mIP2 = UInt8 ((self.mIPAddress >> 16) & 255)
      self.mIP1 = UInt8 ((self.mIPAddress >> 8) & 255)
      self.mIP0 = UInt8 (self.mIPAddress & 255)
    }
    .onChange (of: self.mIP3) { self.updateIPAddress () }
    .onChange (of: self.mIP2) { self.updateIPAddress () }
    .onChange (of: self.mIP1) { self.updateIPAddress () }
    .onChange (of: self.mIP0) { self.updateIPAddress () }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateIPAddress () {
    var ip = UInt32 (self.mIP3) << 24
    ip |= UInt32 (self.mIP2) << 16
    ip |= UInt32 (self.mIP1) <<  8
    ip |= UInt32 (self.mIP0)
    if self.mIPAddress != ip {
      self.mIPAddress = ip
    }
  }
}

//--------------------------------------------------------------------------------------------------

#Preview {
  IPAddressEditor (IPAddressBinding: .constant (0xC0A8011F))
}

//--------------------------------------------------------------------------------------------------
