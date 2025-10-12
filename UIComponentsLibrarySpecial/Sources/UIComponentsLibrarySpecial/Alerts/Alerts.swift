import Lottie
import SwiftUI

// swiftlint:disable file_length

public struct ButtonParams {
    public enum ButtonType {
        case principal
        case secondary
        case tertiary
    }

    let title: String
    let action: () -> Void
    let type: ButtonType
    let reversed: Bool

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

public enum AlertType {
    case input(title: String,
               placeholder: String = "",
               binding: Binding<String>,
               buttons: [ButtonParams]? = nil)
    case message(icon: Image? = nil,
                 animation: LottieAssetProtocol? = nil,
                 title: String,
                 message: String? = nil,
                 buttons: [ButtonParams]? = nil)

    var icon: Image? {
        switch self {
        case .message(let icon, _, _, _, _):
            return icon
        default:
            return nil
        }
    }

    var animation: LottieAssetProtocol? {
        switch self {
        case .message(_, let animation, _, _, _):
            return animation
        default:
            return nil
        }
    }

    var title: String {
        switch self {
        case .message(_, _, let title, _, _):
            return title
        case .input(let title, _, _, _):
            return title
        }
    }

    var message: String? {
        switch self {
        case .message(_, _, _, let message, _):
            return message
        default:
            return nil
        }
    }

    var placeholder: String? {
        switch self {
        case .input(_, let placeholder, _, _):
            return placeholder
        default:
            return nil
        }
    }

    var buttons: [ButtonParams]? {
        switch self {
        case .message(_, _, _, _, let buttons):
            return buttons
        case .input(_, _, _, let buttons):
            return buttons
        }
    }

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

    let width = UIDevice.current.userInterfaceIdiom == .phone ? UIScreen.main.bounds.width * 0.85 : 320

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
            .frame(width: width)
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
    let animation: LottieAssetProtocol

    init?(_ animation: LottieAssetProtocol?) {
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
        .keyboardType(.asciiCapable)
        .disableAutocorrection(true)
        .autocapitalization(.none)
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

    @State var text = ""

    var body: some View {
        VStack {
            PrimaryButton("Message") { alert1 = true }
                .padding()
            SecondaryButton("Icon & Message") { alert2 = true }
                .padding()
            PrimaryButton("Message and Buttons") { alert3 = true }
                .padding()
            SecondaryButton("Icon, Message and Buttons") { alert4 = true }
                .padding()
            PrimaryButton("Input") { alert5 = true }
                .padding()
        }
        .alert(isPresented: $alert1,
               type: .message(title: "Your account has\nsuccessfully been deleted."))
        .alert(isPresented: $alert2,
               type: .message(title: "Update available",
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
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}

// swiftlint:enable file_length
