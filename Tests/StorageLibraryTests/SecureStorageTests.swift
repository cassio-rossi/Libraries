import Foundation
@testable import StorageLibrary
import Testing

@Suite("SecureStorage Tests", .serialized)
struct SecureStorageTests {

    // MARK: - Initialization Tests

    @Test("SecureStorage should initialize with default parameters")
    func testSecureStorageDefaultInitialization() {
        let storage = SecureStorage()

        #expect(storage.service == nil)
        #expect(storage.accessGroup == nil)
    }

    @Test("SecureStorage should initialize with custom service")
    func testSecureStorageCustomServiceInitialization() {
        let service = "com.test.service"
        let storage = SecureStorage(service: service)

        #expect(storage.service == service)
        #expect(storage.accessGroup == nil)
    }

    @Test("SecureStorage should initialize with service and accessGroup")
    func testSecureStorageFullInitialization() {
        let service = "com.test.service"
        let accessGroup = "com.test.group"
        let storage = SecureStorage(service: service, accessGroup: accessGroup)

        #expect(storage.service == service)
        #expect(storage.accessGroup == accessGroup)
    }

    // MARK: - Save and Read Tests

    @Test("SecureStorage should save and read data")
    func testSaveAndReadData() async throws {
        let storage = SecureStorage(service: "com.test.saveread")
        let key = "testKey"
        let value = Data("Test Value".utf8)

        try storage.save(value,
                        key: key,
                        synchronizable: false,
                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        let retrieved = try storage.read(key: key,
                                        synchronizable: false,
                                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        #expect(retrieved == value)

        try storage.delete(key: key,
                          synchronizable: false,
                          accessible: kSecAttrAccessibleAfterFirstUnlock)
    }

    @Test("SecureStorage should handle different accessibility levels")
    func testDifferentAccessibilityLevels() async throws {
        let storage = SecureStorage(service: "com.test.accessibility")
        let key = "accessibilityKey"
        let value = Data("Accessibility Test".utf8)

        let accessibilityLevels: [CFString] = [
            kSecAttrAccessibleAfterFirstUnlock,
            kSecAttrAccessibleWhenUnlocked,
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        for accessible in accessibilityLevels {
            try storage.save(value,
                            key: key,
                            synchronizable: false,
                            accessible: accessible)

            let retrieved = try storage.read(key: key,
                                            synchronizable: false,
                                            accessible: accessible)

            #expect(retrieved == value)

            try storage.delete(key: key,
                              synchronizable: false,
                              accessible: accessible)
        }
    }

    @Test("SecureStorage should handle synchronizable flag")
    func testSynchronizableFlag() async throws {
        let storage = SecureStorage(service: "com.test.sync")
        let key = "syncKey"
        let value = Data("Sync Test".utf8)

        try storage.save(value,
                        key: key,
                        synchronizable: false,
                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        let retrieved = try storage.read(key: key,
                                        synchronizable: false,
                                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        #expect(retrieved == value)

        try storage.delete(key: key,
                          synchronizable: false,
                          accessible: kSecAttrAccessibleAfterFirstUnlock)
    }

    // MARK: - Update Tests

    @Test("SecureStorage should update existing value")
    func testUpdateExistingValue() async throws {
        let storage = SecureStorage(service: "com.test.update")
        let key = "updateKey"
        let value1 = Data("Original Value".utf8)
        let value2 = Data("Updated Value".utf8)

        try storage.save(value1,
                        key: key,
                        synchronizable: false,
                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        try storage.update(value2,
                          key: key,
                          synchronizable: false,
                          accessible: kSecAttrAccessibleAfterFirstUnlock)

        let retrieved = try storage.read(key: key,
                                        synchronizable: false,
                                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        #expect(retrieved == value2)

        try storage.delete(key: key,
                          synchronizable: false,
                          accessible: kSecAttrAccessibleAfterFirstUnlock)
    }

    // MARK: - Delete Tests

    @Test("SecureStorage should delete existing item")
    func testDeleteExistingItem() async throws {
        let storage = SecureStorage(service: "com.test.delete")
        let key = "deleteKey"
        let value = Data("To be deleted".utf8)

        try storage.save(value,
                        key: key,
                        synchronizable: false,
                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        try storage.delete(key: key,
                          synchronizable: false,
                          accessible: kSecAttrAccessibleAfterFirstUnlock)

        #expect(throws: (any Error).self) {
            try storage.read(key: key,
                           synchronizable: false,
                           accessible: kSecAttrAccessibleAfterFirstUnlock)
        }
    }

    // MARK: - Error Tests

    @Test("SecureStorage should throw itemNotFound for non-existent key")
    func testItemNotFoundError() async throws {
        let storage = SecureStorage(service: "com.test.notfound")
        let key = "nonExistentKey"

        #expect(throws: (any Error).self) {
            try storage.read(key: key,
                           synchronizable: false,
                           accessible: kSecAttrAccessibleAfterFirstUnlock)
        }
    }

    @Test("SecureStorage should delete and re-save item manually")
    func testDeleteAndReSaveItem() async throws {
        let storage = SecureStorage(service: "com.test.deleteresave")
        let key = "deleteResaveKey"
        let value1 = Data("First Value".utf8)
        let value2 = Data("Second Value".utf8)

        try storage.save(value1,
                        key: key,
                        synchronizable: false,
                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        // Manually delete then save again
        try storage.delete(key: key,
                          synchronizable: false,
                          accessible: kSecAttrAccessibleAfterFirstUnlock)

        try storage.save(value2,
                        key: key,
                        synchronizable: false,
                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        let retrieved = try storage.read(key: key,
                                        synchronizable: false,
                                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        #expect(retrieved == value2)

        try? storage.delete(key: key,
                           synchronizable: false,
                           accessible: kSecAttrAccessibleAfterFirstUnlock)
    }

    // MARK: - Edge Cases

    @Test("SecureStorage should handle empty data")
    func testEmptyData() async throws {
        let storage = SecureStorage(service: "com.test.empty")
        let key = "emptyKey"
        let value = Data()

        try storage.save(value,
                        key: key,
                        synchronizable: false,
                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        let retrieved = try storage.read(key: key,
                                        synchronizable: false,
                                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        #expect(retrieved == value)
        #expect(retrieved.isEmpty)

        try storage.delete(key: key,
                          synchronizable: false,
                          accessible: kSecAttrAccessibleAfterFirstUnlock)
    }

    @Test("SecureStorage should handle large data")
    func testLargeData() async throws {
        let storage = SecureStorage(service: "com.test.large")
        let key = "largeKey"
        let largeString = String(repeating: "A", count: 10000)
        let value = largeString.data(using: .utf8)

        guard let value = value else {
            Issue.record("Failed to create data")
            return
        }

        try storage.save(value,
                        key: key,
                        synchronizable: false,
                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        let retrieved = try storage.read(key: key,
                                        synchronizable: false,
                                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        #expect(retrieved == value)

        try storage.delete(key: key,
                          synchronizable: false,
                          accessible: kSecAttrAccessibleAfterFirstUnlock)
    }

    @Test("SecureStorage should handle special characters in key")
    func testSpecialCharactersInKey() async throws {
        let storage = SecureStorage(service: "com.test.specialchars")
        let key = "test@#$%^&*()_+-={}[]|:;'<>?,./key"
        let value = Data("Special Key Test".utf8)

        try storage.save(value,
                        key: key,
                        synchronizable: false,
                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        let retrieved = try storage.read(key: key,
                                        synchronizable: false,
                                        accessible: kSecAttrAccessibleAfterFirstUnlock)

        #expect(retrieved == value)

        try storage.delete(key: key,
                          synchronizable: false,
                          accessible: kSecAttrAccessibleAfterFirstUnlock)
    }

    @Test("SecureStorage should handle multiple items")
    func testMultipleItems() async throws {
        let storage = SecureStorage(service: "com.test.multiple")
        let items = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3"
        ]

        for (key, value) in items {
            guard let data = value.data(using: .utf8) else {
                Issue.record("Failed to create data")
                return
            }

            try storage.save(data,
                            key: key,
                            synchronizable: false,
                            accessible: kSecAttrAccessibleAfterFirstUnlock)
        }

        for (key, value) in items {
            let retrieved = try storage.read(key: key,
                                            synchronizable: false,
                                            accessible: kSecAttrAccessibleAfterFirstUnlock)
            let retrievedString = String(data: retrieved, encoding: .utf8)
            #expect(retrievedString == value)
        }

        for key in items.keys {
            try storage.delete(key: key,
                              synchronizable: false,
                              accessible: kSecAttrAccessibleAfterFirstUnlock)
        }
    }
}
