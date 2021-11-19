import Foundation

public struct Match: Codable {
    public var organization: String
    public var accession_number: String
}

public struct Pattern: Codable {
    public var name: String
    public var pattern: String
    public var tests: [String:[String]]
}

public struct Definition: Codable {
    public var organization_name: String
    public var organization_url: String
    public var iiif_manifest: String
    public var oembed_profile: String
    public var object_url: String
    public var whosonfirst_id: Int64
    public var patterns: [Pattern]
}

public func ExtractFromText(text: String, definitions: [Definition]) -> Result<[Match], Error> {
    
    var accession_numbers = [Match]()
    
    for def in definitions {
        
        let rsp = ExtractFromTextWithDefinition(text: text, definition: def)
        
        switch rsp {
        case .failure(let error):
            return .failure(error)
        case .success(let results):
            accession_numbers.append(contentsOf: results)
        }
    }
    
    return .success(accession_numbers)
}

public func ExtractFromTextWithDefinition(text: String, definition: Definition)  -> Result<[Match], Error> {
    
    var accession_numbers = [Match]()
    
    for p in definition.patterns {
        
        let rsp = ExtractFromTextWithPattern(text: text, pattern: p)
        
        switch rsp {
        case .failure(let error):
            return .failure(error)
        case .success(let results):
            
            for var r in results {
                r.organization = definition.organization_url
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
