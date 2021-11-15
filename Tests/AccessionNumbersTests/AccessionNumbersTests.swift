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
        
        var data: Data
        var org: Organization
        
        do {
            data = try Data(contentsOf: url)
        } catch (let error){
            fatalError("Failed to load  from bundle, \(error).")
        }
        
        let decoder = JSONDecoder()
        
        do {
            org = try decoder.decode(Organization.self, from: data)
        } catch (let error){
            fatalError("Failed to load organization, \(error).")
        }
        
        let an = AccessionNumbers(candidates: [org])
             
        for p in org.patterns {
            
            for (t, _) in p.tests {
                
                let rsp = an.ExtractFromTextWithPattern(text:t, pattern: p)
                print(t, rsp)
                
                switch rsp {
                case .failure(let error):
                    fatalError("Failed to extract accession numbers from \(t), \(error).")
                case .success(let results):
                    let count = results.count
                    print(count)
                    // test against expected count here
                }
            }
        }
    }
}
