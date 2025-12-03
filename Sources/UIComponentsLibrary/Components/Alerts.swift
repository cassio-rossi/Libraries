import Lottie
import SwiftUI

// swiftlint:disable file_length

/// Configuration parameters for alert buttons.
///
/// `ButtonParams` defines the appearance and behavior of buttons displayed in custom alerts.
public struct ButtonParams {
	/// Defines the visual style of the button.
    public enum ButtonType {
		/// Primary button with emphasized styling.
        case principal
		/// Secondary button with standard styling.
        case secondary
		/// Tertiary button with minimal styling.
        case tertiary
    }

	/// The text displayed on the button.
    let title: String

	/// The action to execute when the button is tapped.
    let action: () -> Void

	/// The visual style of the button.
    let type: ButtonType

	/// Whether to use reversed colors (e.g., white text on colored background).
    let reversed: Bool

	/// Creates button parameters for custom alerts.
	///
	/// - Parameters:
	///   - title: The text displayed on the button.
	///   - action: The closure to execute when the button is tapped.
	///   - type: The visual style of the button.
	///   - reversed: Whether to use reversed color scheme. Defaults to `false`.
    public init(title: String,
                action: @escaping () -> Void,
                type: ButtonType,
                reversed: Bool) {
        self.title = title
        self.action = action
        self.type = type
        self.reversed = reversed
    }
}

/// Defines the type and content of custom alerts.
///
/// `AlertType` supports two types of alerts:
/// - `.input`: Displays a text field for user input
/// - `.message`: Displays a message with optional icon or animation
public enum AlertType {
	/// An alert that prompts for text input.
	///
	/// - Parameters:
	///   - title: The alert title.
	///   - placeholder: Placeholder text for the input field.
	///   - binding: A binding to store the user's input.
	///   - buttons: Optional array of buttons to display.
    case input(title: String,
               placeholder: String = "",
               binding: Binding<String>,
               buttons: [ButtonParams]? = nil)

	/// An alert that displays a message.
	///
	/// - Parameters:
	///   - icon: Optional static image icon to display.
	///   - animation: Optional Lottie animation to display.
	///   - title: The alert title.
	///   - message: Optional descriptive message.
	///   - buttons: Optional array of buttons to display.
    case message(icon: Image? = nil,
                 animation: LottieAsset? = nil,
                 title: String,
                 message: String? = nil,
                 buttons: [ButtonParams]? = nil)

	/// The icon image for message alerts.
    var icon: Image? {
        switch self {
        case .message(let icon, _, _, _, _):
            return icon
        default:
            return nil
        }
    }

	/// The Lottie animation for message alerts.
    var animation: LottieAsset? {
        switch self {
        case .message(_, let animation, _, _, _):
            return animation
        default:
            return nil
        }
    }

	/// The alert title.
    var title: String {
        switch self {
        case .message(_, _, let title, _, _):
            return title
        case .input(let title, _, _, _):
            return title
        }
    }

	/// The descriptive message for message alerts.
    var message: String? {
        switch self {
        case .message(_, _, _, let message, _):
            return message
        default:
            return nil
        }
    }

	/// The placeholder text for input alerts.
    var placeholder: String? {
        switch self {
        case .input(_, let placeholder, _, _):
            return placeholder
        default:
            return nil
        }
    }

	/// The buttons to display in the alert.
    var buttons: [ButtonParams]? {
        switch self {
        case .message(_, _, _, _, let buttons):
            return buttons
        case .input(_, _, _, let buttons):
            return buttons
        }
    }

	/// The text binding for input alerts.
    var binding: Binding<String>? {
        switch self {
        case .input(_, _, let binding, _):
            return binding
        default:
            return nil
        }
    }
}

extension View {
	/// Presents a custom alert when a binding to a Boolean value is true.
	///
	/// Use this modifier to display custom alerts with more flexibility than
	/// standard system alerts, including Lottie animations, custom styling,
	/// and text input capabilities.
	///
	/// Example:
	/// ```swift
	/// .alert(isPresented: $showAlert,
	///        type: .message(title: "Success", message: "Operation completed"))
	/// ```
	///
	/// - Parameters:
	///   - isPresented: A binding to whether the alert should be presented.
	///   - type: The type and configuration of the alert to display.
	/// - Returns: A view that presents the custom alert when triggered.
    public func alert(isPresented: Binding<Bool>,
                      type: AlertType) -> some View {
        modifier(CustomAlertView(isPresented: isPresented,
                                 alertType: type))
    }
}

private struct CustomAlertView: ViewModifier {
    @Binding var isPresented: Bool
    var alertType: AlertType

    func body(content: Content) -> some View {
        content
            .customFullScreenCover(isPresented: $isPresented) {
                CustomAlert(isPresented: $isPresented,
                            alertType: alertType)
            }
    }
}

struct CustomAlert: View {
    @Binding var isPresented: Bool
    var alertType: AlertType
    @State private var animate = false

    var body: some View {
        ZStack {
            EmptyView()
                .dimmingOverlay(show: $isPresented,
                                allowInteraction: false)

            VStack(spacing: 0) {
                Group {
                    OptionalSpacer(alertType.icon)
                        .padding(.top)
                    OptionalIcon(alertType.icon)
                        .scaleEffect(0.5)
                    OptionalAnimation(alertType.animation)
                }.padding(.bottom, 4)

                OptionalText(alertType.title, relativeTo: .title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorAssetLibrary.black)
                    .padding([.leading, .trailing])
                    .padding(.bottom, 4)

                Group {
                    OptionalText(alertType.message, relativeTo: .body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(ColorAssetLibrary.darkGrey)
                        .padding([.leading, .trailing, .bottom])
                    OptionalSpacer(alertType.message)
                }.padding(.bottom)

                Group {
                    OptionalTextField(alertType.placeholder,
                                      text: alertType.binding,
                                      relativeTo: .body)
                    .padding([.leading, .trailing])
                    .padding(.bottom, 30)
                }.padding(.bottom)

                CustomAlertButtons(isPresented: $isPresented,
                                   animate: $animate,
                                   alertType: alertType)
            }
            .frame(maxWidth: 320)
            .background(Color.white)
            .cornerRadius(14.0)
            .opacity(animate ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.4)) {
                    animate.toggle()
                }
            }
            .if((alertType.buttons ?? []).isEmpty) { view in
                view
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.4)) { animate = false }
                        withAnimation(.easeIn(duration: 0.4).delay(0.4)) { isPresented = false }
                    }
            }
        }
    }
}

struct OptionalIcon: View {
    let image: Image

    init?(_ icon: Image?) {
        guard let icon = icon else { return nil }
        self.image = icon
    }

    var body: some View {
        image
    }
}

struct OptionalAnimation: View {
    let animation: LottieAsset

    init?(_ animation: LottieAsset?) {
        guard let animation = animation else { return nil }
        self.animation = animation
    }

    var body: some View {
        LottieView(asset: animation)
            .frame(width: 82, height: 82)
    }
}

struct OptionalText: View {
    let text: String
    let style: Font.TextStyle

    init?(_ text: String?,
          relativeTo style: Font.TextStyle = .body) {
        guard let text = text else { return nil }
        self.text = text
        self.style = style
    }

    var body: some View {
        Text(AttributedString(text, relativeTo: style))
    }
}

struct OptionalSpacer<T>: View {
    init?(_ text: T?) {
        if text != nil {
            return nil
        }
    }

    var body: some View {
        Text("")
    }
}

struct OptionalTextField: View {
    let placeholder: String
    @Binding var text: String
    let style: Font.TextStyle

    enum FocusedField {
        case textField
    }
    @FocusState private var focusedField: FocusedField?

    init?(_ placeholder: String?,
          text: Binding<String>?,
          relativeTo style: Font.TextStyle = .body) {
        guard let placeholder = placeholder,
              let text = text else { return nil }
        self.placeholder = placeholder
        self.style = style
        _text = text
    }

    var body: some View {
        TextField("\(AttributedString("", relativeTo: style))",
                  text: $text,
                  prompt: Text(AttributedString(placeholder, relativeTo: style)))
        .disableAutocorrection(true)
        .background(Divider().overlay(.black).offset(x: 0, y: 20))
        .focused($focusedField, equals: .textField)
        .onAppear {
            focusedField = .textField
        }
    }
}

struct CustomAlertButtons: View {
    @Binding var isPresented: Bool
    @Binding var animate: Bool
    let alertType: AlertType

    let buttons: [ButtonParams]

    init?(isPresented: Binding<Bool>,
          animate: Binding<Bool>,
          alertType: AlertType) {

        if alertType.buttons == nil {
            return nil
        }

        _isPresented = isPresented
        _animate = animate
        self.alertType = alertType
        self.buttons = alertType.buttons ?? []
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<buttons.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeIn(duration: 0.2)) { animate = false }
                    withAnimation(.easeIn(duration: 0.2).delay(0.2)) { isPresented = false }
                    withAnimation(.easeIn(duration: 0.2).delay(0.4)) { buttons[index].action() }
                }, label: {
                    HStack {
                        Spacer()
                        Text(buttons[index].type == .principal ? buttons[index].title.bodyBold : buttons[index].title.body)
                            .padding([.top, .bottom], 14)
                            .foregroundColor(buttons[index].reversed ? ColorAssetLibrary.white : ColorAssetLibrary.blue)
                        Spacer()
                    }
                    .background(Rectangle()
                        .stroke(ColorAssetLibrary.grey)
                        .background(Rectangle()
                            .fill(buttons[index].reversed ? ColorAssetLibrary.blue : ColorAssetLibrary.white))
                    )
                    .ignoresSafeArea()
                })
            }
        }
    }
}

// MARK: - PREVIEW -

struct AlertView: View {
    @State var alert1 = false
    @State var alert2 = false
    @State var alert3 = false
    @State var alert4 = false
    @State var alert5 = false
    @State var alert6 = false

    @State var text = ""

    var body: some View {
        VStack {
            PrimaryButton("Message") { alert1 = true }
            SecondaryButton("Icon & Message") { alert2 = true }
            PrimaryButton("Message and Buttons") { alert3 = true }
            SecondaryButton("Icon, Message and Buttons") { alert4 = true }
            PrimaryButton("Input") { alert5 = true }
            SecondaryButton("Animation") { alert6 = true }
        }
        .padding(.horizontal)

        .alert(isPresented: $alert1,
               type: .message(title: "Your account has\nsuccessfully been deleted."))

        .alert(isPresented: $alert2,
               type: .message(icon: ImageAssetLibrary.Common.error,
                              title: "Update available",
                              message: "Using mobile data to download may result in additional charges. Using Wi-Fi is recommended."))

        .alert(isPresented: $alert3,
               type: .message(title: "Your account has\nsuccessfully been deleted.",
                              message: "Using mobile data to download may result in additional charges. Using Wi-Fi is recommended.",
                              buttons: [ButtonParams(title: "Cancel",
                                                     action: {},
                                                     type: .secondary,
                                                     reversed: false),
                                        ButtonParams(title: "Continue",
                                                     action: {},
                                                     type: .principal,
                                                     reversed: false)]))

        .alert(isPresented: $alert4,
               type: .message(icon: ImageAssetLibrary.Common.error,
                              title: "Your account has\nsuccessfully been deleted.",
                              message: "Using mobile data to download may result in additional charges. Using Wi-Fi is recommended.",
                              buttons: [ButtonParams(title: "Cancel",
                                                     action: {},
                                                     type: .secondary,
                                                     reversed: true),
                                        ButtonParams(title: "Continue",
                                                     action: {},
                                                     type: .principal,
                                                     reversed: true)]))

        .alert(isPresented: $alert5,
               type: .input(title: "Enter your account name",
                            placeholder: "Account name",
                            binding: $text,
                            buttons: [ButtonParams(title: "Cancel",
                                                   action: {},
                                                   type: .secondary,
                                                   reversed: true),
                                      ButtonParams(title: "Continue",
                                                   action: {},
                                                   type: .principal,
                                                   reversed: true)]))

        .alert(isPresented: $alert6,
               type: .message(
                animation: LottieAsset(string: "search", bundle: .module),
                title: "Your account has\nsuccessfully been deleted.")
        )
    }
}

#Preview {
    AlertView()
}

// swiftlint:enable file_length
