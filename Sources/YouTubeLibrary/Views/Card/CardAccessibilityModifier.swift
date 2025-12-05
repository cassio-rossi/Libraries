import SwiftUI
import UtilityLibrary

public enum CardLabel {
    case title
    case date
    case duration
    case views
    case likes
}

private extension Array where Element == CardLabel {
    func makeText(using data: VideoDB) -> String {
        var text = [String]()
        self.forEach {
            switch $0 {
            case .title: text.append(data.title)
            case .date: text.append("publicado em \(data.pubDate.formattedDate(using: "dd/MM/yyyy"))")
            case .duration: text.append("com duração de \(data.duration.accessibilityTime)")
            case .views: text.append("\(data.views) visualizações")
            case .likes: text.append("\(data.likes) curtidas")
            }
        }
        return "Video " + text.joined(separator: ", ") + "."
    }
}

public enum CardButton {
    case share
    case favorite
}

private extension Array where Element == CardButton {
    @MainActor
    func makeButtons(using data: VideoDB) -> some View {
        ForEach(self.indices, id: \.self) { index in
            switch self[index] {
            case .favorite:
                FavoriteButton(content: data)
            case .share:
                ShareButton(content: data)
            }
        }
    }
}

extension View {
    func cardAccessibility(
        data: VideoDB,
        labels: [CardLabel]?,
        buttons: [CardButton]?
    ) -> some View {
        modifier(CardAccessibilityModifier(
            data: data,
            labels: labels ?? [.title, .date, .duration, .likes, .views],
            buttons: buttons ?? [.favorite, .share])
        )
    }
}

private struct CardAccessibilityModifier: ViewModifier {
    let data: VideoDB
    let labels: [CardLabel]
    let buttons: [CardButton]

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityChildren {
                Text(labels.makeText(using: data))
                    .accessibilityAddTraits(.isButton)
                    .accessibilityHint("Duplo toque para reproduzir o video.")
                buttons.makeButtons(using: data)
            }
    }
}
