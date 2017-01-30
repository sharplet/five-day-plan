enum Scripture {
  struct Book: RawRepresentable {
    typealias RawValue = String

    let rawValue: String
    fileprivate let position: Int

    var osisAbbrevation: String {
      return books[position].0
    }

    init?(rawValue: String) {
      guard let position = books.index(where: { $1 == rawValue })
        ?? alternates[rawValue].flatMap({ book in books.index(where: { $1 == book }) })
        else { return nil }

      self.position = position
      self.rawValue = rawValue
    }

    fileprivate init(unsafeName name: String, position: Int) {
      self.position = position
      self.rawValue = name
    }

    static let all = books.enumerated().map { index, book in
      Book(unsafeName: book.1, position: index)
    }
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
  ("GEN", "Genesis"),
  ("EXO", "Exodus"),
  ("LEV", "Leviticus"),
  ("NUM", "Numbers"),
  ("DEU", "Deuteronomy"),
  ("JOS", "Joshua"),
  ("JDG", "Judges"),
  ("RUT", "Ruth"),
  ("1SA", "1 Samuel"),
  ("2SA", "2 Samuel"),
  ("1KI", "1 Kings"),
  ("2KI", "2 Kings"),
  ("1CH", "1 Chronicles"),
  ("2CH", "2 Chronicles"),
  ("EZR", "Ezra"),
  ("NEH", "Nehemiah"),
  ("EST", "Esther"),
  ("JOB", "Job"),
  ("PSA", "Psalms"),
  ("PRO", "Proverbs"),
  ("ECC", "Ecclesiastes"),
  ("SNG", "Song of Solomon"),
  ("ISA", "Isaiah"),
  ("JER", "Jeremiah"),
  ("LAM", "Lamentations"),
  ("EZK", "Ezekiel"),
  ("DAN", "Daniel"),
  ("HOS", "Hosea"),
  ("JOL", "Joel"),
  ("AMO", "Amos"),
  ("OBA", "Obadiah"),
  ("JON", "Jonah"),
  ("MIC", "Micah"),
  ("NAM", "Nahum"),
  ("HAB", "Habakkuk"),
  ("ZEP", "Zephaniah"),
  ("HAG", "Haggai"),
  ("ZEC", "Zechariah"),
  ("MAL", "Malachi"),
  ("MAT", "Matthew"),
  ("MRK", "Mark"),
  ("LUK", "Luke"),
  ("JHN", "John"),
  ("ACT", "Acts"),
  ("ROM", "Romans"),
  ("1CO", "1 Corinthians"),
  ("2CO", "2 Corinthians"),
  ("GAL", "Galatians"),
  ("EPH", "Ephesians"),
  ("PHP", "Philippians"),
  ("COL", "Colossians"),
  ("1TH", "1 Thessalonians"),
  ("2TH", "2 Thessalonians"),
  ("1TI", "1 Timothy"),
  ("2TI", "2 Timothy"),
  ("TIT", "Titus"),
  ("PHM", "Philemon"),
  ("HEB", "Hebrews"),
  ("JAS", "James"),
  ("1PE", "1 Peter"),
  ("2PE", "2 Peter"),
  ("1JN", "1 John"),
  ("2JN", "2 John"),
  ("3JN", "3 John"),
  ("JUD", "Jude"),
  ("REV", "Revelation"),
]

private let alternates: [String: String] = [
  "Psalm": "Psalms",
]
