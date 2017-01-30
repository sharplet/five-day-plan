enum Scripture {
  struct Book: RawRepresentable {
    typealias RawValue = String

    let rawValue: String
    fileprivate let position: Int

    init?(rawValue: String) {
      guard let position = books.index(of: rawValue)
        ?? alternates[rawValue].flatMap(books.index(of:))
        else { return nil }

      self.position = position
      self.rawValue = rawValue
    }

    fileprivate init(unsafeName name: String, position: Int) {
      self.position = position
      self.rawValue = name
    }

    static let all = books.enumerated().map { Book(unsafeName: $1, position: $0) }
  }

  struct Chapter {
    var book: Book
    var chapter: Int?

    init(book: Book) {
      self.book = book
      self.chapter = nil
    }

    init?(book: Book, chapter: Int) {
      guard chapter >= 1 else { return nil }
      self.book = book
      self.chapter = chapter
    }
  }
}

extension Scripture.Chapter: CustomStringConvertible {
  var description: String {
    var description = book.rawValue

    if let chapter = chapter {
      description.append(" \(chapter)")
    }

    return description
  }
}

private let books = [
  "Genesis",
  "Exodus",
  "Leviticus",
  "Numbers",
  "Deuteronomy",
  "Joshua",
  "Judges",
  "Ruth",
  "1 Samuel",
  "2 Samuel",
  "1 Kings",
  "2 Kings",
  "1 Chronicles",
  "2 Chronicles",
  "Ezra",
  "Nehemiah",
  "Esther",
  "Job",
  "Psalms",
  "Proverbs",
  "Ecclesiastes",
  "Song of Solomon",
  "Isaiah",
  "Jeremiah",
  "Lamentations",
  "Ezekiel",
  "Daniel",
  "Hosea",
  "Joel",
  "Amos",
  "Obadiah",
  "Jonah",
  "Micah",
  "Nahum",
  "Habakkuk",
  "Zephaniah",
  "Haggai",
  "Zechariah",
  "Malachi",
  "Matthew",
  "Mark",
  "Luke",
  "John",
  "Acts",
  "Romans",
  "1 Corinthians",
  "2 Corinthians",
  "Galatians",
  "Ephesians",
  "Philippians",
  "Colossians",
  "1 Thessalonians",
  "2 Thessalonians",
  "1 Timothy",
  "2 Timothy",
  "Titus",
  "Philemon",
  "Hebrews",
  "James",
  "1 Peter",
  "2 Peter",
  "1 John",
  "2 John",
  "3 John",
  "Jude",
  "Revelation",
]

private let alternates: [String: String] = [
  "Psalm": "Psalms",
]
