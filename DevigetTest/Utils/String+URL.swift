//
//  URL+Utils.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 30/09/2020.
//

import Foundation

extension String {
    func validateUrl() -> Bool {
        let regex = "http[s]?://(([^/:.[:space:]]+(.[^/:.[:space:]]+)*)|([0-9](.[0-9]{3})))(:[0-9]+)?((/[^?#[:space:]]+)([^#[:space:]]+)?(#.+)?)?"
                let test = NSPredicate(format:"SELF MATCHES %@", regex)
                let result = test.evaluate(with: self)
                return result
    }
    
    func unescapingURLCharacters() -> String {
            var newString = self
            let char_dictionary = [
                "&amp;" : "&",
                "&lt;" : "<",
                "&gt;" : ">",
                "&quot;" : "\"",
                "&apos;" : "'"
            ];
            for (escaped_char, unescaped_char) in char_dictionary {
                newString = newString.replacingOccurrences(of: escaped_char, with: unescaped_char, options: NSString.CompareOptions.literal, range: nil)
            }
            return newString
    }
}
