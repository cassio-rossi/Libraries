//
//  InAppView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/06/2025.
//

import Combine
import InAppLibrary
import StoreKit
import SwiftUI

struct InAppView: View {
    @ObservedObject private var viewModel = InAppViewModel()
    @State private var customPurchaseView: Int = 0

    var body: some View {
        VStack {
            Picker("Type", selection: $customPurchaseView) {
                Text("Standard").tag(0)
                Text("Custom").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            List(viewModel.products, id: \.identifier) { product in
                button(for: product).padding(4)
            }

            Button(action: { viewModel.restoreSubscriptions() },
                   label: {
                Text("Restore Subscriptions")
            })
        }
        .navigationTitle("InApp Purchase")
        .task {
            try? await viewModel.fetchProducts()
        }
    }
}

extension InAppView {
    @ViewBuilder
    private func button(for product: InAppProduct) -> some View {
        if let identifier = product.identifier,
           customPurchaseView == 0 {
            purchase(identifier)
        } else {
            purchase(product)
        }
    }

    @ViewBuilder
    private func purchase(_ identifier: String) -> some View {
        ProductView(id: identifier)
    }

    @ViewBuilder
    private func purchase(_ product: InAppProduct) -> some View {
        Button(action: { viewModel.purchase(product) },
               label: {
            HStack {
                Text(product.title ?? "")
                    .font(.headline)
                Spacer()
                Text(product.price ?? "")
            }
        })
    }
}

#Preview {
    InAppView()
}

final class InAppViewModel: ObservableObject {
    @Published var products: [InAppProduct] = []
    let inAppLibrary = InAppManager()
    var cancellables: Set<AnyCancellable> = []

    init() {
        setupListeners()
    }

    func setupListeners() {
        Task.detached {
            await self.inAppLibrary.$status
                .receive(on: RunLoop.main)
                .sink { status in
                    print("==> \(status)")
                }
                .store(in: &self.cancellables)
        }
    }

    @MainActor
    func fetchProducts() async throws {
        if await inAppLibrary.canPurchase {
            products = try await inAppLibrary.getProducts(for: ["PRODUCT_1", "PRODUCT_2"])
        }
    }

    func restoreSubscriptions() {
        Task {
            await inAppLibrary.restore()
        }
    }

    func purchase(_ product: InAppProduct) {
        Task {
            await inAppLibrary.purchase(product)
        }
    }
}
