import SwiftUI

/// A customizable search bar with optional placeholder and cancel button.
public struct SearchBar: View {
    @FocusState private var hasFocus: Bool
    private var theme: Themeable?
    @Binding var text: String
    private var placeholder: String?
    private var cancel: String?

    /// Creates a new search bar.
    ///
    /// - Parameters:
    ///   - text: A binding to the search text.
    ///   - placeholder: Optional placeholder text. Default is "Search ...".
    ///   - cancel: Optional cancel button text. Default is "Cancel".
    ///   - theme: Optional theme for styling. Default is nil.
    public init(text: Binding<String>,
                placeholder: String? = nil,
                cancel: String? = nil,
                theme: Themeable? = nil) {
        _text = text
        self.placeholder = placeholder
        self.cancel = cancel
        self.theme = theme
    }

    public var body: some View {
        HStack {
            TextField(placeholder ?? "Search ...", text: $text)
                .padding(6)
                .padding(.horizontal, 32)
                .background(.gray)
                .cornerRadius(8)
                .focused($hasFocus)
                .onTapGesture {
                    hasFocus = true
                }
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }, label: {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            })
                        }
                    }
                )
            if hasFocus {
                Button(action: {
                    text = ""
                    hasFocus = false
                }, label: {
                    Text(cancel ?? "Cancel")
                        .foregroundColor(theme?.text.primary.asColor ?? Color.secondary)
                })
            }
        }
        .onAppear {
            hasFocus = true
        }
    }
}

#Preview {
    SearchBar(text: .constant(""),
              placeholder: "Procurar nas Dicas ...",
              cancel: "Cancelar")
    .padding([.leading, .trailing])
}
