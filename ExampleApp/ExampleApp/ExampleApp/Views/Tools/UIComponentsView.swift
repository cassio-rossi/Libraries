//
//  UIComponentsView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 06/10/2025.
//

import SwiftUI
import UIComponentsLibrary

struct UIComponentsView: View {
    var body: some View {
        ScrollView {
            VStack {
                HeaderView(title: "Action") {}

                Button(action: {},
                       label: { Text("Normal Button") })

                    HStack {
                        PrimaryButton("Primary Button", style: .footnote, action: {})
                        SecondaryButton("Secondary Button", style: .footnote, action: {})
                    }

                    HStack {
                        ImageButton(ImageAssetLibrary.Common.menu,
                                    size: CGSize(width: 30, height: 30),
                                    action: {})
                        ImageButton(ImageAssetLibrary.Common.add,
                                    size: CGSize(width: 50, height: 50),
                                    action: {})
                        ImageButton(ImageAssetLibrary.Common.add,
                                    action: {})
                        .disabled(true)
                    }

                HStack {
                    AvatarView(avatar: "CR",
                               size: 64)
                    CircularProgressView(progress: 0.4,
                                         lineWidth: 10,
                                         color: .blue)
                        .frame(width: 56)
                }

                ErrorView(message: "An error occurred.")

                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationTitle("UI Components")
    }
}

#Preview {
    UIComponentsView()
}
