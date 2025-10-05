import CryptoKit
import Foundation
@testable import StorageLibrary
import Testing

@Suite("SecKeyConvertible Protocol Tests")
struct SecKeyConvertibleTests {

    // MARK: - P256 Signing PrivateKey Tests

    @Test("P256 Signing PrivateKey should have x963Representation")
    func testP256SigningKeyX963Representation() {
        let privateKey = P256.Signing.PrivateKey()
        let representation = privateKey.x963Representation

        #expect(Bool(representation.isEmpty == false))
    }

    @Test("P256 Signing PrivateKey should initialize from x963Representation")
    func testP256SigningKeyInitFromX963() throws {
        let originalKey = P256.Signing.PrivateKey()
        let representation = originalKey.x963Representation

        let recreatedKey = try P256.Signing.PrivateKey(x963Representation: representation)

        #expect(recreatedKey.rawRepresentation == originalKey.rawRepresentation)
    }

    @Test("P256 Signing PrivateKey should have valid description")
    func testP256SigningKeyDescription() {
        let privateKey = P256.Signing.PrivateKey()
        let description = privateKey.description

        #expect(Bool(description.isEmpty == false))
        #expect(description.contains("bytes"))
        #expect(Bool(description.contains("Key representation") == true))
    }

    @Test("P256 Signing PrivateKey description should not leak key data")
    func testP256SigningKeyDescriptionDoesNotLeakData() {
        let privateKey = P256.Signing.PrivateKey()
        let description = privateKey.description
        let rawRep = privateKey.rawRepresentation
        let hexRep = rawRep.map { String(format: "%02x", $0) }.joined()

        #expect(Bool(description.contains(hexRep) == false))
    }

    // MARK: - P256 KeyAgreement PrivateKey Tests

    @Test("P256 KeyAgreement PrivateKey should have x963Representation")
    func testP256KeyAgreementX963Representation() {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let representation = privateKey.x963Representation

        #expect(Bool(representation.isEmpty == false))
    }

    @Test("P256 KeyAgreement PrivateKey should initialize from x963Representation")
    func testP256KeyAgreementInitFromX963() throws {
        let originalKey = P256.KeyAgreement.PrivateKey()
        let representation = originalKey.x963Representation

        let recreatedKey = try P256.KeyAgreement.PrivateKey(x963Representation: representation)

        #expect(recreatedKey.rawRepresentation == originalKey.rawRepresentation)
    }

    @Test("P256 KeyAgreement PrivateKey should have valid description")
    func testP256KeyAgreementDescription() {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let description = privateKey.description

        #expect(Bool(description.isEmpty == false))
        #expect(description.contains("bytes"))
        #expect(Bool(description.contains("Key representation") == true))
    }

    @Test("P256 KeyAgreement PrivateKey description should not leak key data")
    func testP256KeyAgreementDescriptionDoesNotLeakData() {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let description = privateKey.description
        let rawRep = privateKey.rawRepresentation
        let hexRep = rawRep.map { String(format: "%02x", $0) }.joined()

        #expect(Bool(description.contains(hexRep) == false))
    }

    // MARK: - Representation Size Tests

    @Test("P256 Signing PrivateKey x963Representation should have consistent size")
    func testP256SigningKeyRepresentationSize() {
        let keys = (0..<10).map { _ in P256.Signing.PrivateKey() }
        let sizes = Set(keys.map { $0.x963Representation.count })

        #expect(sizes.count == 1)
    }

    @Test("P256 KeyAgreement PrivateKey x963Representation should have consistent size")
    func testP256KeyAgreementRepresentationSize() {
        let keys = (0..<10).map { _ in P256.KeyAgreement.PrivateKey() }
        let sizes = Set(keys.map { $0.x963Representation.count })

        #expect(sizes.count == 1)
    }

    // MARK: - Round-Trip Tests

    @Test("P256 Signing PrivateKey should support round-trip conversion")
    func testP256SigningKeyRoundTrip() throws {
        let originalKey = P256.Signing.PrivateKey()

        let data = originalKey.x963Representation
        let recreatedKey = try P256.Signing.PrivateKey(x963Representation: data)
        let finalData = recreatedKey.x963Representation

        #expect(data == finalData)
        #expect(originalKey.rawRepresentation == recreatedKey.rawRepresentation)
    }

    @Test("P256 KeyAgreement PrivateKey should support round-trip conversion")
    func testP256KeyAgreementRoundTrip() throws {
        let originalKey = P256.KeyAgreement.PrivateKey()

        let data = originalKey.x963Representation
        let recreatedKey = try P256.KeyAgreement.PrivateKey(x963Representation: data)
        let finalData = recreatedKey.x963Representation

        #expect(data == finalData)
        #expect(originalKey.rawRepresentation == recreatedKey.rawRepresentation)
    }

    // MARK: - Multiple Keys Tests

    @Test("Different P256 Signing PrivateKeys should have different representations")
    func testDifferentSigningKeysHaveDifferentRepresentations() {
        let key1 = P256.Signing.PrivateKey()
        let key2 = P256.Signing.PrivateKey()

        let rep1 = key1.x963Representation
        let rep2 = key2.x963Representation

        #expect(rep1 != rep2)
    }

    @Test("Different P256 KeyAgreement PrivateKeys should have different representations")
    func testDifferentKeyAgreementKeysHaveDifferentRepresentations() {
        let key1 = P256.KeyAgreement.PrivateKey()
        let key2 = P256.KeyAgreement.PrivateKey()

        let rep1 = key1.x963Representation
        let rep2 = key2.x963Representation

        #expect(rep1 != rep2)
    }

    // MARK: - Description Format Tests

    @Test("P256 Signing PrivateKey description should contain byte count")
    func testP256SigningKeyDescriptionFormat() {
        let privateKey = P256.Signing.PrivateKey()
        let description = privateKey.description
        let byteCount = privateKey.x963Representation.count

        #expect(description.contains("\(byteCount)"))
        #expect(description.contains("bytes"))
    }

    @Test("P256 KeyAgreement PrivateKey description should contain byte count")
    func testP256KeyAgreementDescriptionFormat() {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let description = privateKey.description
        let byteCount = privateKey.x963Representation.count

        #expect(description.contains("\(byteCount)"))
        #expect(description.contains("bytes"))
    }

    // MARK: - Edge Cases

    @Test("P256 Signing PrivateKey x963Representation should be non-empty")
    func testP256SigningKeyNonEmptyRepresentation() {
        let keys = (0..<5).map { _ in P256.Signing.PrivateKey() }

        for key in keys {
            #expect(Bool(key.x963Representation.isEmpty == false))
        }
    }

    @Test("P256 KeyAgreement PrivateKey x963Representation should be non-empty")
    func testP256KeyAgreementNonEmptyRepresentation() {
        let keys = (0..<5).map { _ in P256.KeyAgreement.PrivateKey() }

        for key in keys {
            #expect(Bool(key.x963Representation.isEmpty == false))
        }
    }

    @Test("SecKeyConvertible protocol should handle Data as ContiguousBytes")
    func testContiguousBytesCompatibility() throws {
        let originalKey = P256.Signing.PrivateKey()
        let data = originalKey.x963Representation

        let dataAsBytes: Data = data
        let recreatedKey = try P256.Signing.PrivateKey(x963Representation: dataAsBytes)

        #expect(recreatedKey.rawRepresentation == originalKey.rawRepresentation)
    }

    @Test("SecKeyConvertible protocol should handle Array as ContiguousBytes")
    func testArrayContiguousBytesCompatibility() throws {
        let originalKey = P256.Signing.PrivateKey()
        let data = originalKey.x963Representation

        let arrayBytes = Array(data)
        let recreatedKey = try P256.Signing.PrivateKey(x963Representation: arrayBytes)

        #expect(recreatedKey.rawRepresentation == originalKey.rawRepresentation)
    }
}
