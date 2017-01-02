extension Collection {
  func at(_ index: Index) -> Iterator.Element? {
    let range = (startIndex..<endIndex)
    guard range.contains(index) else { return nil }
    return self[index]
  }
}
