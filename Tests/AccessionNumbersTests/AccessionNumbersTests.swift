import XCTest
@testable import AccessionNumbers

final class AccessionNumbersTests: XCTestCase {
    
    
    func testExtractAccessionNumbers() throws {        
        
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let url = thisDirectory.appendingPathComponent("TestData/sfomuseum.json")
        
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
        
        // Test Definition methods
        
        let num = "1994.18.165"
        
        let iiif_rsp = def.IIIFManifest(accession_number: num)
        
        switch iiif_rsp {
        case .failure(let error):
            fatalError("Failed to derive IIIF manifest URL for \(num), \(error)")
        case .success(let url):

            let str_uri = url.absoluteString
            let expected_uri = "https://millsfield.sfomuseum.org/objects/1994.18.165/manifest"
            
            if  str_uri != expected_uri {
                fatalError("Invalid IIIF URL, got '\(str_uri)' but expected \(expected_uri)")
            }
        }
        
        let oembed_rsp = def.OEmbedProfile(accession_number: num)
        
        switch oembed_rsp {
        case .failure(let error):
            fatalError("Failed to derive OEmbed profile URL for \(num), \(error)")
        case .success(let url):

            let str_uri = url.absoluteString
            let expected_uri = "https://millsfield.sfomuseum.org/oembed/?url=https://millsfield.sfomuseum.org/objects/1994.18.165&format=json"
            
            if  str_uri != expected_uri {
                fatalError("Invalid OEmbed profile URL, got '\(str_uri)' but expected \(expected_uri)")
            }
        }
        
        let object_rsp = def.ObjectURL(accession_number: num)
        
        switch object_rsp {
        case .failure(let error):
            fatalError("Failed to derive object URL for \(num), \(error)")
        case .success(let url):

            let str_uri = url.absoluteString
            let expected_uri = "https://millsfield.sfomuseum.org/objects/1994.18.165"
            
            if  str_uri != expected_uri {
                fatalError("Invalid object URL, got '\(str_uri)' but expected \(expected_uri)")
            }
        }
    }
}
