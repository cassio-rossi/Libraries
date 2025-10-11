import Foundation
@testable import StorageLibrary
import Testing

@Suite("DefaultStorage Tests", .serialized)
struct StorageTests {

    // MARK: - Initialization Tests

    @Test("DefaultStorage should initialize with standard UserDefaults")
    func testDefaultStorageStandardInitialization() {
        let storage = DefaultStorage(nil)
        #expect(storage.userDefaults == UserDefaults.standard)
    }

    @Test("DefaultStorage should initialize with custom suite")
    func testDefaultStorageCustomSuiteInitialization() {
        let suiteName = "com.test.customsuite"
        let storage = DefaultStorage(suiteName)

        #expect(storage.userDefaults.dictionaryRepresentation().keys.contains(suiteName) == false)
    }

    // MARK: - Save and Get Tests

    @Test("DefaultStorage should save and retrieve String")
    func testSaveAndGetString() {
        let storage = DefaultStorage("com.test.string")
        let key = "testStringKey"
        let value = "Test String Value"

        storage.save(object: value, key: key)
        let retrieved = storage.get(key: key) as? String

        #expect(retrieved == value)

        storage.delete(key: key)
    }

    @Test("DefaultStorage should save and retrieve Int")
    func testSaveAndGetInt() {
        let storage = DefaultStorage("com.test.int")
        let key = "testIntKey"
        let value = 42

        storage.save(object: value, key: key)
        let retrieved = storage.get(key: key) as? Int

        #expect(retrieved == value)

        storage.delete(key: key)
    }

    @Test("DefaultStorage should save and retrieve Bool")
    func testSaveAndGetBool() {
        let storage = DefaultStorage("com.test.bool")
        let key = "testBoolKey"
        let value = true

        storage.save(object: value, key: key)
        let retrieved = storage.get(key: key) as? Bool

        #expect(retrieved == value)

        storage.delete(key: key)
    }

    @Test("DefaultStorage should save and retrieve Double")
    func testSaveAndGetDouble() {
        let storage = DefaultStorage("com.test.double")
        let key = "testDoubleKey"
        let value = 3.14159

        storage.save(object: value, key: key)
        let retrieved = storage.get(key: key) as? Double

        #expect(retrieved == value)

        storage.delete(key: key)
    }

    @Test("DefaultStorage should save and retrieve Data")
    func testSaveAndGetData() {
        let storage = DefaultStorage("com.test.data")
        let key = "testDataKey"
        let value = Data("Test Data".utf8)

        storage.save(object: value, key: key)
        let retrieved = storage.get(key: key) as? Data

        #expect(retrieved == value)

        storage.delete(key: key)
    }

    @Test("DefaultStorage should save and retrieve Array")
    func testSaveAndGetArray() {
        let storage = DefaultStorage("com.test.array")
        let key = "testArrayKey"
        let value = ["one", "two", "three"]

        storage.save(object: value, key: key)
        let retrieved = storage.get(key: key) as? [String]

        #expect(retrieved == value)

        storage.delete(key: key)
    }

    @Test("DefaultStorage should save and retrieve Dictionary")
    func testSaveAndGetDictionary() {
        let storage = DefaultStorage("com.test.dictionary")
        let key = "testDictionaryKey"
        let value = ["key1": "value1", "key2": "value2"]

        storage.save(object: value, key: key)
        let retrieved = storage.get(key: key) as? [String: String]

        #expect(retrieved == value)

        storage.delete(key: key)
    }

    // MARK: - Delete Tests

    @Test("DefaultStorage should delete existing key")
    func testDeleteExistingKey() {
        let storage = DefaultStorage("com.test.delete")
        let key = "testDeleteKey"
        let value = "To be deleted"

        storage.save(object: value, key: key)
        #expect(storage.get(key: key) != nil)

        storage.delete(key: key)
        #expect(storage.get(key: key) == nil)
    }

    @Test("DefaultStorage should handle delete of non-existent key")
    func testDeleteNonExistentKey() {
        let storage = DefaultStorage("com.test.nonexistent")
        let key = "nonExistentKey"

        storage.delete(key: key)
        #expect(storage.get(key: key) == nil)
    }

    // MARK: - Edge Cases

    @Test("DefaultStorage should return nil for non-existent key")
    func testGetNonExistentKey() {
        let storage = DefaultStorage("com.test.getnil")
        let key = "nonExistentKey"

        let retrieved = storage.get(key: key)
        #expect(retrieved == nil)
    }

    @Test("DefaultStorage should overwrite existing value")
    func testOverwriteExistingValue() {
        let storage = DefaultStorage("com.test.overwrite")
        let key = "testOverwriteKey"
        let value1 = "Original Value"
        let value2 = "Updated Value"

        storage.save(object: value1, key: key)
        #expect(storage.get(key: key) as? String == value1)

        storage.save(object: value2, key: key)
        #expect(storage.get(key: key) as? String == value2)

        storage.delete(key: key)
    }

    @Test("DefaultStorage should handle empty string key")
    func testEmptyStringKey() {
        let storage = DefaultStorage("com.test.emptykey")
        let key = ""
        let value = ""

        storage.save(object: value, key: key)
        let retrieved = storage.get(key: key) as? String

        #expect(retrieved == value)

        storage.delete(key: key)
    }

    @Test("DefaultStorage should handle special characters in key")
    func testSpecialCharactersInKey() {
        let storage = DefaultStorage("com.test.specialchars")
        let key = "test@#$%^&*()_+-={}[]|:;'<>?,./key"
        let value = "Special Key Value"

        storage.save(object: value, key: key)
        let retrieved = storage.get(key: key) as? String

        #expect(retrieved == value)

        storage.delete(key: key)
    }

    @Test("DefaultStorage should handle multiple saves and deletes")
    func testMultipleSavesAndDeletes() {
        let storage = DefaultStorage("com.test.multiple")
        let keys = ["key1", "key2", "key3"]
        let values = ["value1", "value2", "value3"]

        for (key, value) in zip(keys, values) {
            storage.save(object: value, key: key)
        }

        for (key, value) in zip(keys, values) {
            #expect(storage.get(key: key) as? String == value)
        }

        for key in keys {
            storage.delete(key: key)
        }

        for key in keys {
            #expect(storage.get(key: key) == nil)
        }
    }
}
