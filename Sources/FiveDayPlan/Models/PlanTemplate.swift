import Foundation

enum PlanTemplateError: Error {
  case invalidScripture(String)
  case missingTitle(String)
  case noSuchTemplate(name: String)
}

struct PlanTemplate {
  var weeks: [Week]

  init(name: String, bundle: Bundle = .main) throws {
    guard let url = bundle.url(forResource: name, withExtension: "txt", subdirectory: "Plans")
      else { throw PlanTemplateError.noSuchTemplate(name: name) }

    let string = try String(contentsOf: url)
    weeks = try string.blocks.map { try Week(text: $0) }
  }
}

extension PlanTemplate {
  struct Week {
    var title: String
    var days: [ScriptureCollection]

    init(text: String) throws {
      let lines = text.enumerated(.byLines).makeIterator()

      guard let title = lines.next() else {
        throw PlanTemplateError.missingTitle(text)
      }
      self.title = title

      days = try lines.map { try makeScriptureCollection($0) }
    }
  }
}

private func makeScriptureCollection(_ line: String) throws -> ScriptureCollection {
  var line = line

  if let bullet = line.range(of: "^-\\s*", options: .regularExpression) {
    line.removeSubrange(bullet)
  }

  var scriptures = ScriptureCollection()

  while !line.isEmpty {
    let scripture: String

    if let separator = line.range(of: ";\\s*", options: .regularExpression) {
      scripture = line.substring(to: separator.lowerBound)
      line.removeSubrange(line.startIndex..<separator.upperBound)
    } else {
      scripture = line
      line.removeAll()
    }

    try scriptures.insert(contentsOf: scripture)
  }

  return scriptures
}

private extension ScriptureCollection {
  mutating func insert(contentsOf scripture: String) throws {
    let scanner = Scanner(string: scripture)
    let book = try scanBook(with: scanner)

    guard !scanner.isAtEnd else {
      let chapter = Scripture.Chapter(book: book)
      self.chapters.append(chapter)
      return
    }

    scanner.scanCharacters(from: .whitespaces, into: nil)

    let chapters = try scanChapters(in: book, with: scanner)
    self.chapters.append(contentsOf: chapters)
  }

  private func scanBook(with scanner: Scanner) throws -> Scripture.Book {
    var number = 0

    if scanner.scanInt(&number) {
      scanner.scanCharacters(from: .whitespaces, into: nil)
    }

    var name: NSString?
    guard scanner.scanUpToCharacters(from: .decimalDigits, into: &name),
      case let trimmedName = name!.trimmingCharacters(in: .whitespaces),
      case let rawValue = (number == 0) ? trimmedName : "\(number) \(trimmedName)",
      let book = Scripture.Book(rawValue: rawValue)
      else { throw PlanTemplateError.invalidScripture(scanner.string) }

    return book
  }

  private func scanChapters(in book: Scripture.Book, with scanner: Scanner) throws -> [Scripture.Chapter] {
    let startingLocation = scanner.scanLocation

    let firstChapter = try scanChapter(in: book, with: scanner)

    defer {
      if !scanner.isAtEnd {
        scanner.scanLocation = startingLocation
      }
    }

    if scanner.scanString("-", into: nil) {
      let lastChapter = try scanChapter(in: book, with: scanner)
      let remaining = (firstChapter.chapter! + 1) ..< lastChapter.chapter!
      var chapters = remaining.map { Scripture.Chapter(book: book, chapter: $0)! }
      chapters.insert(firstChapter, at: 0)
      chapters.append(lastChapter)
      return chapters
    } else if scanner.isAtEnd {
      return [firstChapter]
    } else {
      var chapters = [firstChapter]

      while scanner.scanString(",", into: nil) {
        scanner.scanCharacters(from: .whitespaces, into: nil)
        let chapter = try scanChapter(in: book, with: scanner)
        chapters.append(chapter)
      }

      guard scanner.isAtEnd else {
        throw PlanTemplateError.invalidScripture(scanner.string)
      }

      return chapters
    }
  }

  private func scanChapter(in book: Scripture.Book, with scanner: Scanner) throws -> Scripture.Chapter {
    var rawValue = 0
    guard scanner.scanInt(&rawValue),
      let chapter = Scripture.Chapter(book: book, chapter: rawValue)
      else { throw PlanTemplateError.invalidScripture(scanner.string) }

    return chapter
  }
}

extension PlanTemplate {
  static let year2017: PlanTemplate! = try? PlanTemplate(name: "2017")
}
