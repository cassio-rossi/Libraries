import SwiftUI

public struct CollectionView<Content: View>: View {
    @State private var cardWidth = CGFloat.zero
    @Binding var scrollPosition: ScrollPosition

    private let title: String
    private let status: APIStatus
    private let usesDensity: Bool
    private var favorite: Bool
    private var isSearching: Bool
    private var quantity: Int
    private var density: CardDensity { .density(using: cardWidth) }

    private let retryAction: (() -> Void)?
    private let content: () -> Content

    private let grid = GridItem(
        .adaptive(minimum: 280),
        spacing: 20,
        alignment: .top
    )

    public init(
        title: String,
        status: APIStatus,
        usesDensity: Bool = true,
        scrollPosition: Binding<ScrollPosition>,
        favorite: Bool = false,
        isSearching: Bool = false,
        quantity: Int = 0,
        content: @escaping () -> Content,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.status = status
        self.usesDensity = usesDensity
        self.favorite = favorite
        self.isSearching = isSearching
        self.quantity = quantity
        self.content = content
        self.retryAction = retryAction

        _scrollPosition = scrollPosition
    }

    public var body: some View {
        VStack {
            LoadingAndErrorView(title: title,
                                status: status,
                                favorite: favorite,
                                isSearching: isSearching,
                                quantity: quantity,
                                retryAction: retryAction)

            ScrollView {
                LazyVGrid(columns: Array(repeating: grid, count: usesDensity ? density.columns : 1),
                          spacing: 20) {
                    content()
                }.padding(.horizontal)
            }
            .scrollPosition($scrollPosition)
        }
        .contentWidth { value in
            cardWidth = value
        }
    }
}
