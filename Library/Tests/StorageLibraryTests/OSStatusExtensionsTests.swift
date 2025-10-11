import Foundation
@testable import StorageLibrary
import Testing

@Suite("OSStatus Extension Tests")
struct OSStatusExtensionsTests {

    // MARK: - Success Status Tests

    @Test("OSStatus error should return nil for success")
    func testSuccessStatusReturnsNil() {
        let status: OSStatus = errSecSuccess
        let error = status.error

        #expect(error == nil)
    }

    // MARK: - Error Status Tests

    @Test("OSStatus error should return NSError for itemNotFound")
    func testItemNotFoundError() {
        let status: OSStatus = errSecItemNotFound
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecItemNotFound))
    }

    @Test("OSStatus error should return NSError for duplicateItem")
    func testDuplicateItemError() {
        let status: OSStatus = errSecDuplicateItem
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecDuplicateItem))
    }

    @Test("OSStatus error should return NSError for authFailed")
    func testAuthFailedError() {
        let status: OSStatus = errSecAuthFailed
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecAuthFailed))
    }

    @Test("OSStatus error should return NSError for userCanceled")
    func testUserCanceledError() {
        let status: OSStatus = errSecUserCanceled
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecUserCanceled))
    }

    @Test("OSStatus error should return NSError for interactionNotAllowed")
    func testInteractionNotAllowedError() {
        let status: OSStatus = errSecInteractionNotAllowed
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecInteractionNotAllowed))
    }

    @Test("OSStatus error should return NSError for param error")
    func testParamError() {
        let status: OSStatus = errSecParam
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecParam))
    }

    @Test("OSStatus error should return NSError for allocate error")
    func testAllocateError() {
        let status: OSStatus = errSecAllocate
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecAllocate))
    }

    @Test("OSStatus error should return NSError for notAvailable")
    func testNotAvailableError() {
        let status: OSStatus = errSecNotAvailable
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecNotAvailable))
    }

    @Test("OSStatus error should return NSError for decode error")
    func testDecodeError() {
        let status: OSStatus = errSecDecode
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecDecode))
    }

    @Test("OSStatus error should return NSError for read only error")
    func testReadOnlyError() {
        let status: OSStatus = errSecReadOnly
        let error = status.error

        #expect(error != nil)
        #expect(error?.domain == NSOSStatusErrorDomain)
        #expect(error?.code == Int(errSecReadOnly))
    }

    // MARK: - Error Description Tests

    @Test("OSStatus error should contain localized description")
    func testErrorContainsLocalizedDescription() {
        let status: OSStatus = errSecItemNotFound
        let error = status.error

        #expect(error != nil)
        if let error = error {
            let description = error.userInfo[NSLocalizedDescriptionKey] as? String
            #expect(description != nil)
            #expect(Bool(description?.isEmpty == false))
        }
    }

    @Test("OSStatus error should have valid error message")
    func testErrorHasValidMessage() {
        let statuses: [OSStatus] = [
            errSecItemNotFound,
            errSecDuplicateItem,
            errSecParam,
            errSecAuthFailed
        ]

        for status in statuses {
            let error = status.error
            #expect(error != nil)
            if let error = error {
                let description = error.userInfo[NSLocalizedDescriptionKey] as? String
                #expect(description != nil)
                #expect(Bool(description?.isEmpty == false))
            }
        }
    }

    // MARK: - Domain Tests

    @Test("OSStatus error should use NSOSStatusErrorDomain")
    func testErrorDomain() {
        let statuses: [OSStatus] = [
            errSecItemNotFound,
            errSecDuplicateItem,
            errSecAuthFailed,
            errSecUserCanceled
        ]

        for status in statuses {
            let error = status.error
            #expect(error?.domain == NSOSStatusErrorDomain)
        }
    }

    // MARK: - Code Tests

    @Test("OSStatus error code should match original status")
    func testErrorCodeMatchesStatus() {
        let statuses: [OSStatus] = [
            errSecItemNotFound,
            errSecDuplicateItem,
            errSecAuthFailed,
            errSecUserCanceled,
            errSecParam,
            errSecAllocate
        ]

        for status in statuses {
            let error = status.error
            #expect(error?.code == Int(status))
        }
    }

    // MARK: - Edge Cases

    @Test("OSStatus error should handle zero status")
    func testZeroStatus() {
        let status: OSStatus = 0
        let error = status.error

        #expect(error == nil)
    }

    @Test("OSStatus error should handle custom error codes")
    func testCustomErrorCode() {
        let status: OSStatus = -99999
        let error = status.error

        #expect(error != nil)
        #expect(error?.code == Int(status))
        #expect(error?.domain == NSOSStatusErrorDomain)
    }

    @Test("OSStatus error should handle positive error codes")
    func testPositiveErrorCode() {
        let status: OSStatus = 1
        let error = status.error

        #expect(error != nil)
        #expect(error?.code == 1)
    }
}
