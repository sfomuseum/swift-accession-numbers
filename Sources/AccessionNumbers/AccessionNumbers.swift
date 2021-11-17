import Foundation

public struct Match: Codable {
    public var organization: String
    public var accession_number: String
}

public struct Pattern: Codable {
    public var name: String
    public var pattern: String
    public var tests: [String:Int]
}

public struct Organization: Codable {
    public var name: String
    public var url: String
    public var patterns: [Pattern]
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
                        
            let p = "\\.*?\(pattern.pattern)"
            re = try NSRegularExpression(pattern: p)
        } catch (let error) {
            return .failure(error)
        }
        
        let with_text = text.replacingOccurrences(of: "\n", with: " ")
        var buf = ""
        
        for char in with_text {
                        
            if char == " " {
                
                let found = findMatches(text:buf, re: re)
                
                if found.count == 0 {
                    buf = buf + String(char)
                    continue
                }
                
                for num in found {
                    let m = Match(organization: "", accession_number: num)
                    accession_numbers.append(m)
                }
                
                buf = ""
                
            } else {
                buf = buf + String(char)
            }
        }
        
        if buf != "" {
            
            let found = findMatches(text:buf, re: re)
            
            for num in found {
                let m = Match(organization: "", accession_number: num)
                accession_numbers.append(m)
            }
            
        }
        
        return .success(accession_numbers)
    }
    
    private func findMatches(text: String, re: NSRegularExpression) -> [String] {
                
        let range = NSRange(location: 0, length: text.utf16.count)
        
        let opts: NSRegularExpression.MatchingOptions = [ .withoutAnchoringBounds ]
                
        let matches = re.matches(in: text, options: opts, range: range)
        
        var accession_numbers = [String]()
        
        if let match = matches.first {
                let range = match.range(at:1)
                if let swiftRange = Range(range, in: text) {
                    let num = text[swiftRange]
                    accession_numbers.append(String(num))
                }
        }

        return accession_numbers
    }
    
    
}

