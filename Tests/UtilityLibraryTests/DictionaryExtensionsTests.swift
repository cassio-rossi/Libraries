import Foundation
import Testing
@testable import UtilityLibrary

@Suite("Dictionary tests")
struct DictionaryDebugTests {
    @Test("Empty dictionary produces an empty string")
    func testEmptyDictionary() async throws {
        let dict: [String: Int] = [:]
        #expect(Bool(dict.debugString.isEmpty))
    }

    @Test("Single pair string-int dictionary")
    func testSinglePairStringInt() async throws {
        let dict = ["a": 1]
        let result = dict.debugString
        #expect(result == "a: 1")
    }

    @Test("Multiple pair string-int dictionary")
    func testMultiplePairsStringInt() async throws {
        let dict = ["a": 1, "b": 2]
        let result = dict.debugString
        let validResults = ["a: 1, b: 2", "b: 2, a: 1"] // Dictionary order is not guaranteed
        #expect(validResults.contains(result))
    }

    @Test("Int to String dictionary")
    func testIntKeyStringValue() async throws {
        let dict = [10: "foo", 20: "bar"]
        let result = dict.debugString
        let validResults = ["10: foo, 20: bar", "20: bar, 10: foo"]
        #expect(validResults.contains(result))
    }

    @Test("Custom type values")
    func testCustomTypeValues() async throws {
        struct Foo: CustomStringConvertible, Equatable {
            let value: Int
            var description: String { "Foo(\(value))" }
        }
        let dict = ["foo": Foo(value: 42)]
        #expect(dict.debugString == "foo: Foo(42)")
    }

    @Test("Dictionary debugString should handle nested structures")
    func testDictionaryDebugStringNestedStructures() throws {
        let nestedDict: [String: Any] = [
            "user": ["name": "John", "age": 30],
            "settings": ["theme": "dark", "notifications": true]
        ]

        let result = nestedDict.debugString
        #expect(result.contains("user"))
        #expect(result.contains("settings"))
    }

    @Test("Dictionary debugString should handle mixed value types")
    func testDictionaryDebugStringMixedTypes() throws {
        let mixedDict: [String: Any] = [
            "string": "hello",
            "number": 42,
            "bool": true,
            "array": [1, 2, 3],
            "date": Date()
        ]

        let result = mixedDict.debugString
        #expect(result.contains("hello"))
        #expect(result.contains("42"))
        #expect(result.contains("true"))
    }

    @Test("Dictionary debugString should handle very large dictionaries")
    func testDictionaryDebugStringLargeDictionary() throws {
        var largeDict: [String: Int] = [:]
        for index in 1...100 {
            largeDict["key\(index)"] = index
        }

        let result = largeDict.debugString
        #expect(result.contains("key1"))
        #expect(result.contains("100"))
        #expect(result.count > 100) // Should be a substantial string
    }

    @Test("Dictionary debugString should handle special characters in keys")
    func testDictionaryDebugStringSpecialCharacterKeys() throws {
        let specialDict = [
            "key with spaces": "value1",
            "key@#$%": "value2",
            "émojí🚀": "value3"
        ]

        let result = specialDict.debugString
        #expect(result.contains("key with spaces"))
        #expect(result.contains("émojí🚀"))
    }
}
