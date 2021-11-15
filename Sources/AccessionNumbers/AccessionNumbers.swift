public struct AccessionNumbers {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

public struct Pattern: Codable {
    var Name: String
    var Pattern: String
    var Tests: [String:Int]
}

public struct Organization: Codable {
    var Name: String
    var URL: String
    var Patterns: [Pattern]
}

