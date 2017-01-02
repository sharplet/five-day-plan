extension Sequence {
  var first: Iterator.Element? {
    return first(where: { _ in true })
  }
}
