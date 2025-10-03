import Foundation
import UtilityLibrary

extension String {
    /// Split the content of the log into chuncks because the Console.app truncates the output
    ///
    /// - Parameter lenght: size of the chunck
    /// - Parameter separator: String to identify how the chunck is separated. Default = [...]
    /// - Returns: An array of chuncked Strings
    func split(by length: Int,
               separator: String? = nil) -> [String] {
        if length <= 0 { return [self] }

        var startIndex = self.startIndex
        var results = [String]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex,
                                      offsetBy: length,
                                      limitedBy: self.endIndex) ?? self.endIndex
            results.append(String(self[startIndex..<endIndex]))
            startIndex = endIndex
        }

        // Add separator
        guard let separator = separator, results.count > 1 else {
            return results.isEmpty && self.isEmpty ? [""] : results
        }

        results[0] += "\(separator)"

        let last = results.count - 1
        results[last] = "\(separator)" + results[last]

        for index in 1..<last {
            results[index] = "\(separator)" + results[index] + "\(separator)"
        }

        return results
    }
}
