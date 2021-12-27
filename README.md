# swift-accession-numbers

Swift package for extracting accession numbers from text using the sfomuseum/accession-numbers data.

## Important

This is work in progress. It may still change and lacks documentation.

## Example

```
	import Foundation
	import AccessionNumbers

	let decoder = JSONDecoder()

	guard let url = URL(string: "file:///usr/local/data/sfomuseum.org.json") else {
		// error handling goes here
	}
	
	var data: Data
        var def: Definition

	do {
	        data = try Data(contentsOf: url)
	} catch (let error) {
		// error handling goes here		
	}

	do {
		def = try decoder.decode(Definition.self, from: data)
	} catch (let error) {
		// error handling goes here	
	}

        var candidates  = [Definition]()
        candidates.append(def)

	let text = ""
	
        let rsp = ExtractFromText(text: text, definitions: candidates)

	switch rsp {
	case .failure(let error):
		// error handling goes here	
	case .success(let matches):

		for m in matches {
			print("\(m.accession_number) (\(m.organization))")
		}
	}
```

## Getting started

To get started have a look at [Tests/AccessionNumbersTests/AccessionNumbersTests.swift](https://github.com/sfomuseum/swift-accession-numbers/blob/main/Tests/AccessionNumbersTests/AccessionNumbersTests.swift)

As of this writing this package recognizes accession numbers but is still not able to extract them from arbitrary text, like a wall label. I am still feeling my way around regular expressions in Swift so any help or suggestions would be welcome.

## See also

* https://github.com/sfomuseum/accession-numbers
