//
//  UtilityView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/10/2025.
//

import SwiftUI
import UtilityLibrary

struct UtilityView: View {
    struct MyStruct: Codable {
        let name: String
        let content: String
    }

    var body: some View {
        List {
            Section(header: Text("Obfuscator")) {
                obfuscator
            }
            Section(header: Text("Date")) {
                date
            }
            Section(header: Text("String")) {
                string
            }
            Section(header: Text("Dictionary")) {
                dictionary
            }
            Section(header: Text("Codable")) {
                codable
            }
        }
        .navigationTitle("Utlity")
    }
}

extension UtilityView {
    @ViewBuilder
    private var obfuscator: some View {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])

        Text("Salt: salt")
        Text("Content: [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31]")
        Text("Content: \(revealed)")
    }

    @ViewBuilder
    private var date: some View {
        Text(Date().format())
        Text(Date().format(using: .dateTime))
        Text(Date().format(using: .hourOnly))
        Text(Date().format(using: .live))
    }

    @ViewBuilder
    private var string: some View {
        Text("\("10/10/1910 10:10:10".toDate("dd/MM/yyyy HH:mm:ss"))")
        Text("\("10/10/1910".toDate())")
    }

    @ViewBuilder
    private var dictionary: some View {
        Text(["key": "value"].debugString)
    }

    @ViewBuilder
    private var codable: some View {
        Text(MyStruct(name: "name", content: "content").debugString)
    }
}

#Preview {
    UtilityView()
}
