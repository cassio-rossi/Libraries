import Foundation
@testable import LoggerLibrary
import Testing

@Suite("FileManager Extensions Tests", .serialized)
class FileManagerExtensionsTests {

    let testFileName = "test_file.txt"
    let testContent = "Hello, World!"

    init() {
        // Clean up any existing test files
        FileManager.default.delete(filename: testFileName)
    }

    deinit {
        // Clean up after tests
        FileManager.default.delete(filename: testFileName)
    }

    @Test("Documents directory should return valid URL")
    func testDocumentsDirectory() throws {
        let documentsURL = FileManager.default.documentsDirectory

        #expect(documentsURL.lastPathComponent == "Documents")
        #expect(documentsURL.isFileURL == true)
    }

    @Test("Documents directory should be consistent")
    func testDocumentsDirectoryConsistency() throws {
        let url1 = FileManager.default.documentsDirectory
        let url2 = FileManager.default.documentsDirectory

        #expect(url1 == url2)
    }

    @Test("Exists should return false for non-existent file")
    func testExistsReturnsFalseForNonExistentFile() throws {
        #expect(FileManager.default.exists(filename: "non_existent_file.txt") == false)
    }

    @Test("Exists should return false for nil filename")
    func testExistsReturnsFalseForNilFilename() throws {
        #expect(FileManager.default.exists(filename: nil) == false)
    }

    @Test("Exists should return false for empty filename")
    func testExistsReturnsFalseForEmptyFilename() throws {
        #expect(FileManager.default.exists(filename: "") == false)
    }

    @Test("Save and exists should work together")
    func testSaveAndExists() throws {
        // Ensure file doesn't exist initially
        FileManager.default.delete(filename: testFileName)
        #expect(FileManager.default.exists(filename: testFileName) == false)

        // Save content to file
        FileManager.default.save(testContent, filename: testFileName)

        // Check that file now exists
        #expect(FileManager.default.exists(filename: testFileName) == true)
    }

    @Test("Save should handle nil filename gracefully")
    func testSaveWithNilFilename() throws {
        // This should not crash
        FileManager.default.save(testContent, filename: nil)

        // Verify no file was created (can't test directly, but we can ensure no crash occurred)
        #expect(Bool(true)) // If we reach this line, no crash occurred
    }

    @Test("Content should return saved content")
    func testContentReturnsSavedContent() throws {
        // Save content
        FileManager.default.save(testContent, filename: testFileName)

        // Retrieve content
        let retrievedContent = FileManager.default.content(filename: testFileName)
        #expect(retrievedContent?.trimmingCharacters(in: .newlines) == testContent)
    }

    @Test("Content should return nil for non-existent file")
    func testContentReturnsNilForNonExistentFile() throws {
        let content = FileManager.default.content(filename: "non_existent_file.txt")
        #expect(content == nil)
    }

    @Test("Content should return nil for nil filename")
    func testContentReturnsNilForNilFilename() throws {
        let content = FileManager.default.content(filename: nil)
        #expect(content == nil)
    }

    @Test("Save should append content to existing file")
    func testSaveAppendsToExistingFile() throws {
        let firstContent = "First line"
        let secondContent = "Second line"

        // Save first content
        FileManager.default.save(firstContent, filename: testFileName)

        // Save second content (should append)
        FileManager.default.save(secondContent, filename: testFileName)

        // Retrieve content
        let retrievedContent = FileManager.default.content(filename: testFileName)

        #expect(retrievedContent?.contains(firstContent) == true)
        #expect(retrievedContent?.contains(secondContent) == true)
    }

    @Test("Delete should remove existing file")
    func testDeleteRemovesExistingFile() throws {
        // Create file
        FileManager.default.save(testContent, filename: testFileName)
        #expect(FileManager.default.exists(filename: testFileName) == true)

        // Delete file
        FileManager.default.delete(filename: testFileName)
        #expect(FileManager.default.exists(filename: testFileName) == false)
    }

    @Test("Delete should handle non-existent file gracefully")
    func testDeleteHandlesNonExistentFile() throws {
        // Try to delete non-existent file (should not crash)
        FileManager.default.delete(filename: "non_existent_file.txt")

        #expect(Bool(true)) // If we reach this line, no crash occurred
    }

    @Test("Delete should handle nil filename gracefully")
    func testDeleteHandlesNilFilename() throws {
        // This should not crash
        FileManager.default.delete(filename: nil)

        #expect(Bool(true)) // If we reach this line, no crash occurred
    }

    @Test("Multiple file operations should work correctly")
    func testMultipleFileOperations() throws {
        let fileName1 = "test1.txt"
        let fileName2 = "test2.txt"
        let content1 = "Content 1"
        let content2 = "Content 2"

        defer {
            FileManager.default.delete(filename: fileName1)
            FileManager.default.delete(filename: fileName2)
        }

        // Save multiple files
        FileManager.default.save(content1, filename: fileName1)
        FileManager.default.save(content2, filename: fileName2)

        // Verify both exist
        #expect(FileManager.default.exists(filename: fileName1) == true)
        #expect(FileManager.default.exists(filename: fileName2) == true)

        // Verify contents are correct
        #expect(FileManager.default.content(filename: fileName1)?.trimmingCharacters(in: .newlines) == content1)
        #expect(FileManager.default.content(filename: fileName2)?.trimmingCharacters(in: .newlines) == content2)

        // Delete one file
        FileManager.default.delete(filename: fileName1)

        // Verify only one still exists
        #expect(FileManager.default.exists(filename: fileName1) == false)
        #expect(FileManager.default.exists(filename: fileName2) == true)
    }
}
