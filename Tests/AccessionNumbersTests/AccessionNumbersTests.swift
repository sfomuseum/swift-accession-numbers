import XCTest
@testable import AccessionNumbers

final class AccessionNumbersTests: XCTestCase {

    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // XCTAssertEqual(AccessionNumbers().text, "Hello, World!")
        
        
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let url = thisDirectory.appendingPathComponent("TestData/aic.json")
                                                               
        print("POO")
            print(url.absoluteString)
        
        guard let data = try? Data(contentsOf: url) else {
                    fatalError("Failed to load  from bundle.")
                }

                let decoder = JSONDecoder()

                guard let loaded = try? decoder.decode([String: Organization].self, from: data) else {
                    fatalError("Failed to decode from bundle.")
                }

                print(loaded)
        
    }
}
