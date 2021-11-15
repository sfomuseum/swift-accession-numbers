import Foundation

public struct AccessionNumber: Codable {
    var organization: String
    var number: String
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
    
    public func ExtractFromText(text: String) -> Result<[AccessionNumber], Error> {
        
        var accession_numbers = [AccessionNumber]()
        
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
    
    public func ExtractFromTextWithOrganization(text: String, organization: Organization)  -> Result<[AccessionNumber], Error> {
        
        var accession_numbers = [AccessionNumber]()
        
        for p in organization.patterns {
            
            let rsp = self.ExtractFromTextWithPattern(text: text, pattern: p)
            
            switch rsp {
            case .failure(let error):
                return .failure(error)
            case .success(let results):
                // append org name here
                accession_numbers.append(contentsOf: results)
            }
        }
        return .success(accession_numbers)
    }
    
    public func ExtractFromTextWithPattern(text: String, pattern: Pattern)  -> Result<[AccessionNumber], Error> {
        
        var accession_numbers = [AccessionNumber]()
        
        var re: NSRegularExpression
        
        do {
            re = try NSRegularExpression(pattern: pattern.pattern)
        } catch (let error) {
            return .failure(error)
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        
        let results = re.matches(in: text, options: [], range: range)
        
        for r in results {
            
            let a = AccessionNumber(organization: "", number: r.debugDescription)
            accession_numbers.append(a)
        }
        
        return .success(accession_numbers)
    }
    
    
}

