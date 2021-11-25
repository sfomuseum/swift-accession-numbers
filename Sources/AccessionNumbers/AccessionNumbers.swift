import Foundation
import URITemplate

public struct Match: Codable {
    public var organization: String
    public var accession_number: String
}

public struct Pattern: Codable {
    public var label: String
    public var pattern: String
    public var tests: [String:[String]]
}

public enum DefinitionError: Error {
    case noIIIFTemplate
    case noOEmbedProfileTemplate
    case noObjectURLTemplate
    case invalidURL
}

public struct Definition: Codable {
    public var organization_name: String
    public var organization_url: String
    public var iiif_manifest: String?
    public var oembed_profile: String?
    public var object_url: String?
    public var whosonfirst_id: Int64?
    public var patterns: [Pattern]
        
    public func IIIFManifest(accession_number: String) -> Result<URL, Error> {
        
        if self.iiif_manifest == nil {
            return .failure(DefinitionError.noIIIFTemplate)
        }
        
        if self.iiif_manifest == "" {
            return .failure(DefinitionError.noIIIFTemplate)
        }
        
        let t = URITemplate(template: self.iiif_manifest!)
        return self.expandURITemplate(template: t, accession_number: accession_number)
    }
    
    public func OEmbedProfile(accession_number: String) -> Result<URL, Error> {
        
        if self.oembed_profile == nil {
            return .failure(DefinitionError.noOEmbedProfileTemplate)
        }
        
        if self.oembed_profile == "" {
            return .failure(DefinitionError.noOEmbedProfileTemplate)
        }
        
        let t = URITemplate(template: self.oembed_profile!)
        return self.expandURITemplate(template: t, accession_number: accession_number)
    }
    
    public func ObjectURL(accession_number: String) -> Result<URL, Error> {
        
        if self.object_url == nil {
            return .failure(DefinitionError.noObjectURLTemplate)
        }
        
        if self.object_url == "" {
            return .failure(DefinitionError.noObjectURLTemplate)
        }
        
        let t = URITemplate(template: self.object_url!)
        return self.expandURITemplate(template: t, accession_number: accession_number)
    }

    private func expandURITemplate(template: URITemplate, accession_number: String) -> Result<URL, Error> {
        
        let str_uri = template.expand(["accession_number": accession_number])
        
       let url = URL(string: str_uri)
        
        if url == nil {
            return .failure(DefinitionError.invalidURL)
        }
        
        return .success(url!)
    }
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
    
    let with_text = text.replacingOccurrences(of: "\\n", with: " ")
    var buf = ""
    var seen = ""
    
    for char in with_text {
        
        seen += String(char)
        
        if char == " " {
            
            var found = findMatches(text:buf, re: re)
            
            if found.count == 0 {
                buf = buf + String(char)
                continue
            }
            
            // In order to account for things like `2000.058.1185 a c` (sfomuseum)
            // we need to continue read ahead testing buf until it *doesn't* match.
            // That is, given `2000.058.1185 a c`:
            // `2000.058.1185`       matches
            // `2000.058.1185 `      matches
            // `2000.058.1185 a`     matches
            // `2000.058.1185 a`     matches
            // `2000.058.1185 a `    matches
            // `2000.058.1185 a c`   matches
            // `2000.058.1185 a c `  matches
            // `2000.058.1185 a c (` does not match
                        
            let remaining = with_text.replacingOccurrences(of: seen, with: "")
            
            buf += String(char)
            
            for char_more in remaining {
            
                buf += String(char_more)
                
                let found_more = findMatches(text:buf, re: re)
                
                if found_more.count == 0 {
                    break
                }
                
                found = found_more
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
