import SwiftUI

public struct CheckBoxButton<T: Hashable>: View where T: RawRepresentable {
    @State var selected = [T]()
    @State var error = [T]()

    var items: [T]
    var color: Color = .primary
    var errorColor: Color = .red
    var callback: (([T]) -> Void)?

    public init(items: [T],
                selected: [T] = [],
                error: [T] = [],
                color: Color = .primary,
                errorColor: Color = .red,
                callback: (([T]) -> Void)? = nil) {
        self.items = items
        self.color = color
        self.errorColor = errorColor
        self.callback = callback

        _selected = .init(initialValue: selected)
        _error = .init(initialValue: error)
    }

    public var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    if selected.contains(item) {
                        selected = selected.filter { $0 != item }
                    } else {
                        selected.append(item)
                    }
                    callback?(selected)
                }, label: {
                    CheckBoxButtonItem(title: "\(item.rawValue)",
                                       selected: selected.contains(item),
                                       error: error.contains(item),
                                       color: color,
                                       errorColor: errorColor)
                    .padding([.top, .bottom], 0)
                })
            }
        }
    }
}

struct CheckBoxButtonItem: View {
    let title: String
    let accessibilityValue: String
    let icon: String
    let color: Color

    init(title: String,
         selected: Bool,
         error: Bool,
         color: Color = .primary,
         errorColor: Color = .red) {
        self.title = title
        self.color = error ? errorColor : color

        self.icon = selected ? "checkmark.circle" : error ? "xmark.circle" : "circle"
        self.accessibilityValue = selected ? "Selecionado" : ""
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
            Text(title)
                .accessibility(value: Text(accessibilityValue))
            Spacer()
        }
        .foregroundColor(color)
        .padding([.trailing, .leading], 20)
    }
}

#Preview {
    enum List: String, CaseIterable {
        case button1 = "Button 1"
        case button2 = "Button 2"
    }

    return VStack {
        CheckBoxButton(items: List.allCases)
        Divider()
        CheckBoxButton(items: List.allCases,
                       selected: [List.button1])
        Divider()
        CheckBoxButton(items: List.allCases,
                       error: [List.button1])
        Divider()
        CheckBoxButton(items: List.allCases,
                       selected: [List.button1],
                       error: [List.button2])
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding(.top)
}
