import Testing

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
}
