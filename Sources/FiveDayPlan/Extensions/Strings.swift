import Foundation

extension String {
  var blocks: AnySequence<String> {
    enum ScanMode {
      case accumulate(from: String.Index)
      case skip
    }

    return AnySequence { () -> AnyIterator<String> in
      var mode = ScanMode.skip
      var searchRange = self.startIndex..<self.endIndex

      return AnyIterator {
        var blockRange: Range<Index>?

        self.enumerateSubstrings(in: searchRange, options: .byLines) { substring, _, lineRange, stop in
          defer { searchRange = lineRange.upperBound..<searchRange.upperBound }

          switch (mode, substring) {
          case let (.accumulate(startIndex), .some("")),
               let (.accumulate(startIndex), .none):
            mode = .skip
            blockRange = startIndex..<lineRange.lowerBound
            stop = true

          case (.accumulate, .some),
               (.skip, .some("")),
               (.skip, .none):
            break

          case (.skip, .some):
            mode = .accumulate(from: lineRange.lowerBound)
          }

          if case let (.accumulate(startIndex), self.endIndex) = (mode, lineRange.upperBound) {
            blockRange = startIndex..<lineRange.upperBound
          }
        }

        return blockRange.map(self.substring(with:))
      }
    }
  }

  func enumerated(_ options: String.EnumerationOptions) -> AnySequence<String> {
    return AnySequence { () -> AnyIterator<String> in
      var searchRange = self.startIndex ..< self.endIndex

      return AnyIterator {
        var nextLine: String?
        self.enumerateSubstrings(in: searchRange, options: options) { line, _, range, stop in
          nextLine = line
          searchRange = range.upperBound ..< searchRange.upperBound
          stop = true
        }
        return nextLine
      }
    }
  }
}
