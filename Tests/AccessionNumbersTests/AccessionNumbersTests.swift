import XCTest
@testable import AccessionNumbers

final class AccessionNumbersTests: XCTestCase {
    
    
    func testExtractAccessionNumbers() throws {        
        
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let url = thisDirectory.appendingPathComponent("TestData/moma.json")
        
        var data: Data
        var def: Definition
        
        do {
            data = try Data(contentsOf: url)
        } catch (let error){
            fatalError("Failed to load  from bundle, \(error).")
        }
        
        let decoder = JSONDecoder()
        
        do {
            def = try decoder.decode(Definition.self, from: data)
        } catch (let error){
            fatalError("Failed to load organization, \(error).")
        }
        
        let definitions = [def]
             
        for p in def.patterns {

            
            for (t, expected_results) in p.tests {
                                
                let expected_count = expected_results.count
                
                if expected_count == 0 {
                    continue
                }
                
                let rsp = ExtractFromTextWithPattern(text:t, pattern: p)
                
                switch rsp {
                case .failure(let error):
                    fatalError("Failed to extract accession numbers from \(t), \(error).")
                case .success(let results):
                    
                    let count = results.count
                    
                    if count != expected_count {
                        
                        fatalError("Unexpected count extracting text from \(t) with \(p.pattern). Expected \(expected_count) but got \(count) : \(results)")
                    }
                }
            }
        }
        
        for p in def.patterns {
            
            for (t, expected_results) in p.tests {
               
                let expected_count = expected_results.count
                
                if expected_count == 0 {
                    continue
                }
                
                let rsp = ExtractFromTextWithDefinition(text: t, definition: def)
                
                switch rsp {
                case .failure(let error):
                    fatalError("Failed to extract accession numbers from \(t) for org, \(error).")
                case .success(let results):
                    let count = results.count
                    
                    if count != expected_count {
                        
                        fatalError("Unexpected count extracting text from \(t) with org. Expected \(expected_count) but got \(count)")
                    }
                }
            }
        }
        
        for p in def.patterns {
            
            for (t, _) in p.tests {
                
                let rsp = ExtractFromText(text: t, definitions: [def])
                
                switch rsp {
                case .failure(let error):
                    fatalError("Failed to extract accession numbers from \(t), \(error).")
                case .success(let results):
                    let count = results.count
                    
                    if count == 0 {
                        fatalError("Unexpected count extracting text from \(t). Got zero count.")
                    }
                }
            }

        }
    }
}
