//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Manuel Teixeira on 25/02/2021.
//

import SwiftUI

class UserSettings: ObservableObject {
    @Published var isGoBackToStack = false
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("cards options")) {
                    Toggle("Go back to stack if wrong", isOn: $settings.isGoBackToStack)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button("Done", action: dismiss))
        }
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
