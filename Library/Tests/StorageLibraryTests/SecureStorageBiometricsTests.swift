import CryptoKit
import Foundation
import LocalAuthentication
@testable import StorageLibrary
import Testing

@Suite("SecureStorage Biometrics Tests", .serialized, .disabled("Biometric tests require passcode/biometric setup"))
struct SecureStorageBiometricsTests {

    // MARK: - Save and Read Tests

    @Test("SecureStorage should save and read P256 Signing PrivateKey")
    func testSaveAndReadP256SigningKey() async throws {
        let storage = SecureStorage(service: "com.test.biometric.signing")
        let key = "signingKey"
        let privateKey = P256.Signing.PrivateKey()
        let context = LAContext()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .biometryAny)
        }

        let retrieved: P256.Signing.PrivateKey = try storage.read(
            key: key,
            authenticationContext: context,
            accessControl: .biometryAny
        )

        #expect(retrieved.rawRepresentation == privateKey.rawRepresentation)

        try storage.delete(key: key, accessControl: .biometryAny)
    }

    @Test("SecureStorage should save and read P256 KeyAgreement PrivateKey")
    func testSaveAndReadP256KeyAgreementKey() async throws {
        let storage = SecureStorage(service: "com.test.biometric.agreement")
        let key = "agreementKey"
        let privateKey = P256.KeyAgreement.PrivateKey()
        let context = LAContext()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .biometryAny)
        }

        let retrieved: P256.KeyAgreement.PrivateKey = try storage.read(
            key: key,
            authenticationContext: context,
            accessControl: .biometryAny
        )

        #expect(retrieved.rawRepresentation == privateKey.rawRepresentation)

        try storage.delete(key: key, accessControl: .biometryAny)
    }

    // MARK: - Access Control Tests

    @Test("SecureStorage should handle userPresence access control")
    func testUserPresenceAccessControl() async throws {
        let storage = SecureStorage(service: "com.test.biometric.presence")
        let key = "presenceKey"
        let privateKey = P256.Signing.PrivateKey()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .userPresence)
        }

        try storage.delete(key: key, accessControl: .userPresence)
    }

    @Test("SecureStorage should handle biometryAny access control")
    func testBiometryAnyAccessControl() async throws {
        let storage = SecureStorage(service: "com.test.biometric.any")
        let key = "anyKey"
        let privateKey = P256.Signing.PrivateKey()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .biometryAny)
        }

        try storage.delete(key: key, accessControl: .biometryAny)
    }

    @Test("SecureStorage should handle biometryCurrentSet access control")
    func testBiometryCurrentSetAccessControl() async throws {
        let storage = SecureStorage(service: "com.test.biometric.currentset")
        let key = "currentSetKey"
        let privateKey = P256.Signing.PrivateKey()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .biometryCurrentSet)
        }

        try storage.delete(key: key, accessControl: .biometryCurrentSet)
    }

    // MARK: - Delete Tests

    @Test("SecureStorage should delete biometric key")
    func testDeleteBiometricKey() async throws {
        let storage = SecureStorage(service: "com.test.biometric.delete")
        let key = "deleteKey"
        let privateKey = P256.Signing.PrivateKey()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .userPresence)
        }

        #expect(throws: Never.self) {
            try storage.delete(key: key, accessControl: .userPresence)
        }
    }

    // MARK: - Error Tests

    @Test("SecureStorage should handle duplicate biometric save")
    func testDuplicateBiometricSave() async throws {
        let storage = SecureStorage(service: "com.test.biometric.duplicate")
        let key = "duplicateKey"
        let privateKey1 = P256.Signing.PrivateKey()
        let privateKey2 = P256.Signing.PrivateKey()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey1,
                           key: key,
                           accessControl: .userPresence)
        }

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey2,
                           key: key,
                           accessControl: .userPresence)
        }

        try storage.delete(key: key, accessControl: .userPresence)
    }

    @Test("SecureStorage should throw itemNotFound for non-existent biometric key")
    func testItemNotFoundForNonExistentKey() async throws {
        let storage = SecureStorage(service: "com.test.biometric.notfound")
        let key = "nonExistentKey"
        let context = LAContext()

        #expect(throws: (any Error).self) {
            let _: P256.Signing.PrivateKey = try storage.read(
                key: key,
                authenticationContext: context,
                accessControl: .userPresence
            )
        }
    }

    // MARK: - Service and AccessGroup Tests

    @Test("SecureStorage should save biometric key with service")
    func testSaveBiometricKeyWithService() async throws {
        let storage = SecureStorage(service: "com.test.biometric.service")
        let key = "serviceKey"
        let privateKey = P256.Signing.PrivateKey()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .userPresence)
        }

        try storage.delete(key: key, accessControl: .userPresence)
    }

    @Test("SecureStorage should save biometric key with service and accessGroup")
    func testSaveBiometricKeyWithServiceAndAccessGroup() async throws {
        let storage = SecureStorage(service: "com.test.biometric.full",
                                   accessGroup: "com.test.group")
        let key = "fullKey"
        let privateKey = P256.Signing.PrivateKey()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .userPresence)
        }

        try storage.delete(key: key, accessControl: .userPresence)
    }

    // MARK: - Key Type Tests

    @Test("SecureStorage should handle multiple different key types")
    func testMultipleDifferentKeyTypes() async throws {
        let storage = SecureStorage(service: "com.test.biometric.types")
        let signingKey = P256.Signing.PrivateKey()
        let agreementKey = P256.KeyAgreement.PrivateKey()
        let context = LAContext()

        #expect(throws: Never.self) {
            try storage.save(biometric: signingKey,
                           key: "signingKey",
                           accessControl: .userPresence)
        }

        #expect(throws: Never.self) {
            try storage.save(biometric: agreementKey,
                           key: "agreementKey",
                           accessControl: .userPresence)
        }

        let retrievedSigning: P256.Signing.PrivateKey = try storage.read(
            key: "signingKey",
            authenticationContext: context,
            accessControl: .userPresence
        )

        let retrievedAgreement: P256.KeyAgreement.PrivateKey = try storage.read(
            key: "agreementKey",
            authenticationContext: context,
            accessControl: .userPresence
        )

        #expect(retrievedSigning.rawRepresentation == signingKey.rawRepresentation)
        #expect(retrievedAgreement.rawRepresentation == agreementKey.rawRepresentation)

        try storage.delete(key: "signingKey", accessControl: .userPresence)
        try storage.delete(key: "agreementKey", accessControl: .userPresence)
    }

    // MARK: - Edge Cases

    @Test("SecureStorage should handle special characters in biometric key")
    func testSpecialCharactersInBiometricKey() async throws {
        let storage = SecureStorage(service: "com.test.biometric.special")
        let key = "test@#$%^&*()_+-={}[]|:;'<>?,./key"
        let privateKey = P256.Signing.PrivateKey()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .userPresence)
        }

        try storage.delete(key: key, accessControl: .userPresence)
    }

    @Test("SecureStorage should handle empty string key for biometric")
    func testEmptyStringKeyForBiometric() async throws {
        let storage = SecureStorage(service: "com.test.biometric.empty")
        let key = ""
        let privateKey = P256.Signing.PrivateKey()

        #expect(throws: Never.self) {
            try storage.save(biometric: privateKey,
                           key: key,
                           accessControl: .userPresence)
        }

        try storage.delete(key: key, accessControl: .userPresence)
    }

    @Test("SecureStorage should preserve key uniqueness across different services")
    func testKeyUniquenessAcrossServices() async throws {
        let storage1 = SecureStorage(service: "com.test.biometric.service1")
        let storage2 = SecureStorage(service: "com.test.biometric.service2")
        let key = "sharedKey"
        let privateKey1 = P256.Signing.PrivateKey()
        let privateKey2 = P256.Signing.PrivateKey()
        let context = LAContext()

        #expect(throws: Never.self) {
            try storage1.save(biometric: privateKey1,
                            key: key,
                            accessControl: .userPresence)
        }

        #expect(throws: Never.self) {
            try storage2.save(biometric: privateKey2,
                            key: key,
                            accessControl: .userPresence)
        }

        let retrieved1: P256.Signing.PrivateKey = try storage1.read(
            key: key,
            authenticationContext: context,
            accessControl: .userPresence
        )

        let retrieved2: P256.Signing.PrivateKey = try storage2.read(
            key: key,
            authenticationContext: context,
            accessControl: .userPresence
        )

        #expect(retrieved1.rawRepresentation == privateKey1.rawRepresentation)
        #expect(retrieved2.rawRepresentation == privateKey2.rawRepresentation)
        #expect(retrieved1.rawRepresentation != retrieved2.rawRepresentation)

        try storage1.delete(key: key, accessControl: .userPresence)
        try storage2.delete(key: key, accessControl: .userPresence)
    }
}
