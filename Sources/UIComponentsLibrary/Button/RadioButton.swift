import SwiftUI

public struct RadioButton<T: Hashable>: View where T: RawRepresentable {
    var items: [T]
    var color: Color = .primary
    @State var selected: T?
    var callback: ((T) -> Void)?

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
