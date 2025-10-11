import Foundation
@testable import StorageLibrary
import Testing

// MARK: - Cookies Tests

@Suite("Cookies Tests")
struct CookiesTests {

    // MARK: - Initialization Tests

    @Test("Cookies should initialize with storage")
    func testCookiesInitialization() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        #expect(cookies.storage.get(key: "cookies") == nil)
    }

    // MARK: - Save and Restore Tests

    @Test("Cookies should save and restore single cookie")
    func testSaveAndRestoreSingleCookie() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        guard let cookie = HTTPCookie(properties: [
            .domain: "example.com",
            .path: "/",
            .name: "testCookie",
            .value: "testValue",
            .expires: Date().addingTimeInterval(3600)
        ]) else {
            Issue.record("Failed to create HTTPCookie")
            return
        }

        cookies.save(cookies: [cookie])
        let restored = cookies.restore()

        #expect(restored.count == 1)
        #expect(restored.first?.name == "testCookie")
        #expect(restored.first?.value == "testValue")
        #expect(restored.first?.domain == "example.com")
    }

    @Test("Cookies should save and restore multiple cookies")
    func testSaveAndRestoreMultipleCookies() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        let cookieProperties: [[HTTPCookiePropertyKey: Any]] = [
            [
                .domain: "example.com",
                .path: "/",
                .name: "cookie1",
                .value: "value1",
                .expires: Date().addingTimeInterval(3600)
            ],
            [
                .domain: "test.com",
                .path: "/api",
                .name: "cookie2",
                .value: "value2",
                .expires: Date().addingTimeInterval(7200)
            ],
            [
                .domain: "another.com",
                .path: "/",
                .name: "cookie3",
                .value: "value3",
                .expires: Date().addingTimeInterval(10800)
            ]
        ]

        let httpCookies = cookieProperties.compactMap { HTTPCookie(properties: $0) }
        #expect(httpCookies.count == 3)

        cookies.save(cookies: httpCookies)
        let restored = cookies.restore()

        #expect(restored.count == 3)

        let names = restored.map { $0.name }.sorted()
        #expect(names == ["cookie1", "cookie2", "cookie3"])

        let values = restored.map { $0.value }.sorted()
        #expect(values == ["value1", "value2", "value3"])
    }

    @Test("Cookies should handle empty cookie array")
    func testEmptyCookieArray() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        cookies.save(cookies: [])
        let restored = cookies.restore()

        #expect(restored.isEmpty)
    }

    @Test("Cookies should restore empty array when no cookies saved")
    func testRestoreWithNoSavedCookies() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        let restored = cookies.restore()

        #expect(restored.isEmpty)
    }

    @Test("Cookies should overwrite existing cookies")
    func testOverwriteExistingCookies() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        guard let cookie1 = HTTPCookie(properties: [
            .domain: "example.com",
            .path: "/",
            .name: "cookie1",
            .value: "value1",
            .expires: Date().addingTimeInterval(3600)
        ]) else {
            Issue.record("Failed to create HTTPCookie")
            return
        }

        guard let cookie2 = HTTPCookie(properties: [
            .domain: "test.com",
            .path: "/",
            .name: "cookie2",
            .value: "value2",
            .expires: Date().addingTimeInterval(3600)
        ]) else {
            Issue.record("Failed to create HTTPCookie")
            return
        }

        cookies.save(cookies: [cookie1])
        let firstRestore = cookies.restore()
        #expect(firstRestore.count == 1)
        #expect(firstRestore.first?.name == "cookie1")

        cookies.save(cookies: [cookie2])
        let secondRestore = cookies.restore()
        #expect(secondRestore.count == 1)
        #expect(secondRestore.first?.name == "cookie2")
    }

    // MARK: - Edge Cases

    @Test("Cookies should handle cookies with all properties")
    func testCookiesWithAllProperties() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        guard let cookie = HTTPCookie(properties: [
            .domain: "example.com",
            .path: "/api/v1",
            .name: "fullCookie",
            .value: "fullValue",
            .expires: Date().addingTimeInterval(3600),
            .secure: true
        ]) else {
            Issue.record("Failed to create HTTPCookie")
            return
        }

        cookies.save(cookies: [cookie])
        let restored = cookies.restore()

        #expect(restored.count == 1)
        if let restoredCookie = restored.first {
            #expect(restoredCookie.name == "fullCookie")
            #expect(restoredCookie.value == "fullValue")
            #expect(restoredCookie.domain == "example.com")
            #expect(restoredCookie.path == "/api/v1")
            #expect(restoredCookie.isSecure == true)
        }
    }

    @Test("Cookies should handle cookies with special characters in value")
    func testCookiesWithSpecialCharacters() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        guard let cookie = HTTPCookie(properties: [
            .domain: "example.com",
            .path: "/",
            .name: "specialCookie",
            .value: "value@#$%^&*()_+-={}[]|:;<>?,./",
            .expires: Date().addingTimeInterval(3600)
        ]) else {
            Issue.record("Failed to create HTTPCookie")
            return
        }

        cookies.save(cookies: [cookie])
        let restored = cookies.restore()

        #expect(restored.count == 1)
        #expect(restored.first?.value == "value@#$%^&*()_+-={}[]|:;<>?,./")
    }

    @Test("Cookies should handle session cookies")
    func testSessionCookies() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        guard let cookie = HTTPCookie(properties: [
            .domain: "example.com",
            .path: "/",
            .name: "sessionCookie",
            .value: "sessionValue"
        ]) else {
            Issue.record("Failed to create HTTPCookie")
            return
        }

        cookies.save(cookies: [cookie])
        let restored = cookies.restore()

        #expect(restored.count == 1)
        #expect(restored.first?.name == "sessionCookie")
        #expect(restored.first?.value == "sessionValue")
    }

    @Test("Cookies should preserve cookie order")
    func testCookieOrder() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        let cookieProperties: [[HTTPCookiePropertyKey: Any]] = [
            [.domain: "a.com", .path: "/", .name: "cookieA", .value: "valueA"],
            [.domain: "b.com", .path: "/", .name: "cookieB", .value: "valueB"],
            [.domain: "c.com", .path: "/", .name: "cookieC", .value: "valueC"]
        ]

        let httpCookies = cookieProperties.compactMap { HTTPCookie(properties: $0) }
        cookies.save(cookies: httpCookies)
        let restored = cookies.restore()

        #expect(restored.count == 3)
    }

    @Test("Cookies should handle large number of cookies")
    func testLargeNumberOfCookies() {
        let storage = DefaultStorage(#function)
        let cookies = Cookies(storage: storage)

        var httpCookies: [HTTPCookie] = []
        for index in 0..<100 {
            if let cookie = HTTPCookie(properties: [
                .domain: "example.com",
                .path: "/",
                .name: "cookie\(index)",
                .value: "value\(index)"
            ]) {
                httpCookies.append(cookie)
            }
        }

        #expect(httpCookies.count == 100)

        cookies.save(cookies: httpCookies)
        let restored = cookies.restore()

        #expect(restored.count == 100)
    }
}
