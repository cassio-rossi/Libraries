//
//  StorageView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/10/2025.
//

import StorageLibrary
import SwiftData
import SwiftUI

@Model
public final class ExampleDB {
    public var id: String = ""
    public var date: Date = Date()

    public init(
        id: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.date = date
    }
}

@MainActor
@Observable
class ViewModel {
    let models: [any PersistentModel.Type] = [ExampleDB.self]
    let storage: Database

    init() {
        self.storage = Database(models: models, inMemory: false)
    }

    @MainActor
    func createRecord() {
        let record = ExampleDB(id: UUID().uuidString)
        storage.context.insert(record)
        try? storage.context.save()
    }
}

struct StorageView: View {
    @Environment(ViewModel.self) var viewModel
    @Query private var records: [ExampleDB]

    init() {
        _records = Query(
            filter: nil,
            sort: \ExampleDB.date,
            order: .reverse,
            animation: .smooth
        )
    }

    var body: some View {
        List {
            Section(header: Text("DefaultStorage")) {
                userDefaults
            }
            Section(header: HStack {
                Text("Database")
                Spacer()
                Button(action: { viewModel.createRecord() },
                       label: { Text("Add Record") })
            }) {
                database
            }
        }
        .navigationTitle("Storage")
        .task(id: viewModel.storage.status) {
            print("==> \(viewModel.storage.status)")
        }
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

extension StorageView {
    @ViewBuilder
    private var database: some View {
        Text("#records: \(records.count)")
        Text("Database status: \(viewModel.storage.status, default: "")")
    }
}

#Preview {
    StorageView()
}
