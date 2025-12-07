//
//  InAppView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/06/2025.
//

import InAppLibrary
import StoreKit
import SwiftUI

struct InAppView: View {
    @State private var viewModel = InAppViewModel()
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

            Button(action: {
                Task {
                    await viewModel.restoreSubscriptions()
                }
            }, label: {
                Text("Restore Subscriptions")
            })

            // Display status
            if viewModel.inAppLibrary.status != .unknown {
                Text("Status: \(String(describing: viewModel.inAppLibrary.status))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
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
        Button(action: {
            Task {
                await viewModel.purchase(product)
            }
        }, label: {
            HStack {
                Text(product.title ?? "")
                    .font(.headline)
                Spacer()
                Text(product.price ?? "")
            }
        })
    }
}

@MainActor
@Observable
final class InAppViewModel {
    var products: [InAppProduct] = []
    let inAppLibrary = InAppManager()

    func fetchProducts() async throws {
        if inAppLibrary.canPurchase {
            products = try await inAppLibrary.getProducts(for: ["PRODUCT_1", "PRODUCT_2"])
        }
    }

    func restoreSubscriptions() async {
        await inAppLibrary.restore()
    }

    func purchase(_ product: InAppProduct) async {
        await inAppLibrary.purchase(product)
    }
}

#Preview {
    InAppView()
}
