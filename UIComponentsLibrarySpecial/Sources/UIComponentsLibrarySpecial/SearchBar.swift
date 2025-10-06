import SwiftUI
import UIComponentsLibrary

public struct SearchBar: View {
    @FocusState private var hasFocus: Bool
    private var theme: Themeable?
    @Binding var text: String
    private var placeholder: String?
    private var cancel: String?

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
                .background(Color(.systemGray5))
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
                        .foregroundColor(theme?.text.primary.asColor ?? Color(UIColor.label))
                })
            }
        }
        .onAppear {
            hasFocus = true
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""),
                  placeholder: "Procurar nas Dicas ...",
                  cancel: "Cancelar")
        .padding([.leading, .trailing])
    }
}
