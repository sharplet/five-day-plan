enum TargetEnvironment {
  static var isSimulator: Bool {
#if targetEnvironment(simulator)
    return true
#else
    return false
#endif
  }
}
