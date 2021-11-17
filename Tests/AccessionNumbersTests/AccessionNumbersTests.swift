import XCTest
@testable import AccessionNumbers

final class AccessionNumbersTests: XCTestCase {
    
    
    func testExtractAccessionNumbers() throws {        
        
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let url = thisDirectory.appendingPathComponent("TestData/moma.json")
        
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
            
            for (t, expected_count) in p.tests {
                
                let rsp = an.ExtractFromTextWithPattern(text:t, pattern: p)
                
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
        
        for p in org.patterns {
            
            for (t, expected_count) in p.tests {
               
                let rsp = an.ExtractFromTextWithOrganization(text: t, organization: org)
                
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
        
        for p in org.patterns {
            
            for (t, _) in p.tests {
                
                let rsp = an.ExtractFromText(text: t)
                
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
            
            let label_text = "This is an object\\nGift of Important Donor\\n302.2021.x1-x2\\n\\nThis is another object\\nAnonymouts Gift\\nPG731.2019 146.2020"
            
            let rsp = an.ExtractFromText(text: label_text)
            
            switch rsp {
            case .failure(let error):
                fatalError("Failed to extract accession numbers from label text, \(error).")
            case .success(let results):
                let count = results.count
                
                if count != 3 {
                        fatalError("Failed to extract (2) accession numbers from label text \(results)")
                }
                
            }
        }
    }
}
