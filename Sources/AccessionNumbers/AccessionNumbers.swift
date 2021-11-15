import Foundation

public struct AccessionNumber: Codable {
    var Organization: String
    var Number: String
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
        
        for p in organization.Patterns {
            
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
            re = try NSRegularExpression(pattern: pattern.Pattern)
        } catch (let error) {
            return .failure(error)
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        
        let results = re.matches(in: text, options: [], range: range)
        
        for r in results {
            
            let a = AccessionNumber(Organization: "", Number: r.debugDescription)                
            accession_numbers.append(a)
        }
        
        return .success(accession_numbers)
    }
    
    
}

