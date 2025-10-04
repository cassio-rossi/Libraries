//
//  StorageView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/10/2025.
//

import StorageLibrary
import SwiftUI

struct StorageView: View {
    var body: some View {
        List {
            Section(header: Text("DefaultStorage")) {
                userDefaults
            }
        }
        .navigationTitle("Storage")
    }
}

extension StorageView {
    private var userDefaults: some View {
        let storage = DefaultStorage("")
        storage.save(object: "My Content", key: "key")
        guard let result = storage.get(key: "key") as? String else {
            return Text("Cannot get the content stored")
        }
        return Text(result)
    }
}

#Preview {
    StorageView()
}
