//
//  AlertView.swift
//  Electrolux_Test
//
//  Created by koh kar heng on 03/04/2022.
//

import Foundation
import SwiftUI

public extension View {
  func alert(isPresented: Binding<Bool>,
             title: String,
             message: String? = nil,
             primaryButton: Alert.Button? = nil,
             secondaryButton: Alert.Button? = nil) -> some View {
    
    alert(isPresented: isPresented) {
      if let priButton = primaryButton, let secButton = secondaryButton {
        return Alert(title: Text(title),
                     message: {
          if let message = message { return Text(message) }
          else { return nil } }(),
                     primaryButton: priButton, secondaryButton: secButton)
      } else {
        return Alert(title: Text(title),
                     message: {
          if let message = message { return Text(message) }
          else { return nil } }(),
                     dismissButton: primaryButton)
      }
    }
  }
}
