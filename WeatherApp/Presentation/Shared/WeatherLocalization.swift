//
//  WeatherLocalization.swift
//  WeatherApp
//

import Foundation

enum WeatherL10n {
    static func string(_ key: String, locale: Locale) -> String {
        let missingSentinel = "\u{FFFC}"
        for code in candidateLanguageCodes(locale) {
            if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                let value = bundle.localizedString(forKey: key, value: missingSentinel, table: nil)
                if value != missingSentinel {
                    return value
                }
            }
        }

        let fallback = Bundle.main.localizedString(forKey: key, value: missingSentinel, table: nil)
        if fallback != missingSentinel {
            return fallback
        }
        return key
    }

    private static func candidateLanguageCodes(_ locale: Locale) -> [String] {
        var ids: [String] = []

        func push(_ raw: String) {
            guard !raw.isEmpty else { return }
            let code = raw.replacingOccurrences(of: "_", with: "-")
            guard code != "und" else { return }
            if !ids.contains(code) {
                ids.append(code)
            }
            guard let hyphen = code.firstIndex(of: "-") else { return }
            let langOnly = String(code[..<hyphen])
            guard langOnly != "und", !ids.contains(langOnly) else { return }
            ids.append(langOnly)
        }

        push(locale.language.minimalIdentifier)
        push(locale.identifier)
        return ids
    }

    static func titleStyleDateSubstringAfterComma(in formattedDate: String, locale: Locale) -> String {
        guard let range = formattedDate.range(of: ", ") else { return formattedDate }
        let head = formattedDate[..<range.upperBound]
        let tail = formattedDate[range.upperBound...]
        guard let firstLetterIdx = tail.firstIndex(where: { $0.isLetter }) else {
            return formattedDate
        }
        let before = tail[..<firstLetterIdx]
        let letter = tail[firstLetterIdx]
        let afterIdx = tail.index(after: firstLetterIdx)
        let afterTail = tail[afterIdx...]
        let capped = String(letter).uppercased(with: locale)
        return String(head) + String(before) + capped + String(afterTail)
    }

    static func capitalizeFirstLetter(in string: String, locale: Locale) -> String {
        guard let letterIdx = string.firstIndex(where: { $0.isLetter }) else { return string }
        let before = string[..<letterIdx]
        let letter = string[letterIdx]
        let afterIdx = string.index(after: letterIdx)
        let after = string[afterIdx...]
        return String(before) + String(letter).uppercased(with: locale) + String(after)
    }
}
