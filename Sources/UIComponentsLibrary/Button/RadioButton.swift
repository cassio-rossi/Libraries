import SwiftUI

/// A radio button group that allows single selection from a list of items.
///
/// `RadioButton` displays a vertical list of radio button items where users can select only one option
/// at a time. Each item shows a filled circle icon when selected or an empty circle when unselected.
/// The generic type `T` must conform to both `Hashable` and `RawRepresentable` protocols.
///
/// - Note: The raw value of each item is used as its display label.
public struct RadioButton<T: Hashable>: View where T: RawRepresentable {
    var items: [T]
    var color: Color = .primary
    @State var selected: T?
    var callback: ((T) -> Void)?

    /// Creates a radio button group.
    ///
    /// - Parameters:
    ///   - items: The array of items to display as radio buttons.
    ///   - color: The color for the radio button items. Defaults to `.primary`.
    ///   - selected: The initially selected item. Defaults to `nil` (no selection).
    ///   - callback: Optional closure called with the selected item whenever the selection changes.
    public init(items: [T],
                color: Color = .primary,
                selected: T? = nil,
                callback: ((T) -> Void)? = nil) {
        self.items = items
        self.color = color
        _selected = .init(initialValue: selected)
        self.callback = callback
    }

    public var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    selected = item
                    callback?(item)
                },
                       label: {
                    RadioButtonItem(title: "\(item.rawValue)",
                                    selected: selected == item,
                                    color: color)
                    .padding([.top, .bottom], 0)
                })
            }
        }
    }
}

struct RadioButtonItem: View {
    var title: String
    var selected: Bool
    var color: Color = .primary

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
            Text(title)
                .accessibility(value: Text(selected ? "Selecionado" : ""))
            Spacer()
        }
        .foregroundColor(color)
        .padding([.trailing, .leading], 20)
    }
}

struct RadioButton_Previews: PreviewProvider {
    enum List: String, CaseIterable {
        case button1 = "Button 1"
        case button2 = "Button 2"
    }

    static var previews: some View {
        Group {
            RadioButton(items: List.allCases)
            RadioButton(items: List.allCases, selected: List.button1)
        }
    }
}
