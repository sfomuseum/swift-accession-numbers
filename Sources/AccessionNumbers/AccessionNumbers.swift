import Foundation

public struct Match: Codable {
    var organization: String
    var accession_number: String
}

public struct Pattern: Codable {
    var name: String
    var pattern: String
    var tests: [String:Int]
}

public struct Organization: Codable {
    var name: String
    var url: String
    var patterns: [Pattern]
}

public struct AccessionNumbers {
    
    private var candidates: [Organization]
    
    public init(candidates: [Organization]) {
        self.candidates = candidates
    }
    
    public func ExtractFromText(text: String) -> Result<[Match], Error> {
        
        var accession_numbers = [Match]()
        
        for org in self.candidates {
            
            let rsp = self.ExtractFromTextWithOrganization(text: text, organization: org)
            
            switch rsp {
            case .failure(let error):
                return .failure(error)
            case .success(let results):
                accession_numbers.append(contentsOf: results)
            }
        }
        
        return .success(accession_numbers)
    }
    
    public func ExtractFromTextWithOrganization(text: String, organization: Organization)  -> Result<[Match], Error> {
        
        var accession_numbers = [Match]()
        
        for p in organization.patterns {
            
            let rsp = self.ExtractFromTextWithPattern(text: text, pattern: p)
            
            switch rsp {
            case .failure(let error):
                return .failure(error)
            case .success(let results):
                
                for var r in results {
                    r.organization = organization.url
                    accession_numbers.append(r)
                }
            }
        }
        
        return .success(accession_numbers)
    }
    
    public func ExtractFromTextWithPattern(text: String, pattern: Pattern)  -> Result<[Match], Error> {
        
        var accession_numbers = [Match]()
        
        var re: NSRegularExpression
        
        do {
            
            // I am here trying to sort out multi-line, multi-word regular expressions...
            
            let p = "\\b\(pattern.pattern)\\b"
            re = try NSRegularExpression(pattern: p)
        } catch (let error) {
            return .failure(error)
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        
        let opts: NSRegularExpression.MatchingOptions = [ .withoutAnchoringBounds ]
                
        let matches = re.matches(in: text, options: opts, range: range)
        
        if let match = matches.first {
                let range = match.range(at:1)
                if let swiftRange = Range(range, in: text) {
                    let num = text[swiftRange]
                    // Test num here...
                    let m = Match(organization: "", accession_number: String(num))
                    print("M \(m)")
                    accession_numbers.append(m)
                }
            }
    
        
        return .success(accession_numbers)
    }
    
    
}

