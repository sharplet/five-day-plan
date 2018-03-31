import Foundation

extension String {
  var blocks: AnySequence<Substring> {
    enum ScanMode {
      case accumulate(from: String.Index)
      case skip
    }

    return AnySequence { () -> AnyIterator<Substring> in
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

        return blockRange.map { self[$0] }
      }
    }
  }

  func enumerated(_ options: String.EnumerationOptions) -> AnySequence<Substring> {
    let options = options.union(.substringNotRequired)
    return AnySequence { () -> AnyIterator<Substring> in
      var searchRange = self.startIndex ..< self.endIndex

      return AnyIterator {
        var nextLine: Substring?
        self.enumerateSubstrings(in: searchRange, options: options) { _, range, enclosingRange, stop in
          nextLine = self[range]
          searchRange = enclosingRange.upperBound ..< searchRange.upperBound
          stop = true
        }
        return nextLine
      }
    }
  }
}
