# XCUITest — Critical User Flows

Only automate the 3 most critical journeys. More than that becomes a maintenance burden.
Typical critical flows: **Login**, **Core Feature Action**, **Purchase/Paywall**.

---

## XCUITest base class

```swift
// UITests/Base/BaseUITestCase.swift
import XCTest

class BaseUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["mock", "uitesting"]  // activates NetworkMock
        app.launchEnvironment = ["mapper": MockDataEncoder.base64Encoded()]
        app.launch()
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }
}
```

---

## Login flow test

```swift
// UITests/Flows/LoginFlowTests.swift
final class LoginFlowTests: BaseUITestCase {

    func test_login_withValidCredentials_navigatesToHome() {
        // Arrange — app launches on Login screen
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        // Act
        emailField.tap()
        emailField.typeText("alice@example.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Assert
        let homeTitle = app.navigationBars["Home"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5))
    }

    func test_login_withInvalidCredentials_showsError() {
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]

        emailField.tap()
        emailField.typeText("wrong@example.com")

        passwordField.tap()
        passwordField.typeText("wrongpassword")

        loginButton.tap()

        // Error message should appear
        let errorText = app.staticTexts["loginErrorMessage"]
        XCTAssertTrue(errorText.waitForExistence(timeout: 3))
    }
}
```

---

## Accessibility identifiers in Views

Every interactive element that UI tests need to tap should have an identifier:

```swift
TextField("Email", text: $email)
    .accessibilityIdentifier("emailField")

SecureField("Password", text: $password)
    .accessibilityIdentifier("passwordField")

Button("Log In") { }
    .accessibilityIdentifier("loginButton")

// Error view
if let errorView = ErrorView(message: viewModel.loginError) {
    errorView.accessibilityIdentifier("loginErrorMessage")
}
```

---

## Page Object pattern for maintainability

```swift
// UITests/Pages/LoginPage.swift
struct LoginPage {
    let app: XCUIApplication

    var emailField: XCUIElement { app.textFields["emailField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var errorMessage: XCUIElement { app.staticTexts["loginErrorMessage"] }

    func login(email: String, password: String) {
        emailField.tap()
        emailField.typeText(email)
        passwordField.tap()
        passwordField.typeText(password)
        loginButton.tap()
    }
}

// In test:
func test_login_success() {
    let page = LoginPage(app: app)
    page.login(email: "alice@example.com", password: "password123")
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
}
```
