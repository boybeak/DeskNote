//
//  TestView.swift
//  DeskNote
//
//  Created by Beak on 2024/7/4.
//

import SwiftUI

struct TestView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var selectedColor: Color = .white

    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                Toggle("Remember Me", isOn: $rememberMe)
            }

            Section(header: Text("Preferences")) {
                ColorPicker("Select Color", selection: $selectedColor)
            }
            
            Section {
                Button("Submit") {
                    // Handle submit action
                }
            }
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity) // 设置窗口大小
    }
}
