//
//  day1.swift
//  AoC2023
//
//  Created by Rachael Worthington on 11/30/23.
//

import Foundation

func day1() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day1/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        
        // do something interesting
        part2(with: text)
    } catch {
        print(error.localizedDescription)
    }
}

func part1(with input: String) {
    var total = 0
    input.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let firstDigit = findFirstDigit(of: line)
            let lastDigit = findLastDigit(of: line)
            let value = Int("\(firstDigit)\(lastDigit)")
            total = total + (value ?? 0)
        }

    })
    print(total)
}

func findFirstDigit(of line: String) -> Character {
    let firstHit = line.first { char in
        let charStr = String(char)
        if CharacterSet.decimalDigits.contains(Unicode.Scalar(charStr) ?? " ") {
            return true
        } else {
            return false
        }
    }

    return firstHit ?? " "
}

func findLastDigit(of line: String) -> Character {
    let lastHit = line.last { char in
        let charStr = String(char)
        if CharacterSet.decimalDigits.contains(Unicode.Scalar(charStr) ?? " ") {
            return true
        } else {
            return false
        }
    }

    return lastHit ?? " "
}

let searchTerms: [String: Int] = ["one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "0": 0 ]

func part2(with input: String) {
    var total = 0
    input.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            total = total + (findFirstDigit2(of: line) )
        }
    })
    print(total)
}

func findFirstDigit2(of line: String) -> Int {
    print("line: \(line)")
    var hits: Dictionary<String, [String.Index]> = [:]//[(String, String.Index)] = [] // key hit, index of hit
    let terms = Array(searchTerms.keys)
    var searchRange: Range<String.Index> = Range(uncheckedBounds: (lower: line.startIndex, upper: line.endIndex))
    for index in 0..<searchTerms.count {
        while let range = line.range(of: terms[index], range: searchRange) {
            var currentHitsForDigit = hits[terms[index]] ?? []
            currentHitsForDigit.append(range.lowerBound)
            hits[terms[index]] = currentHitsForDigit
            searchRange = Range(uncheckedBounds: (lower: line.index(after: range.lowerBound), upper: line.endIndex))
        }
        // reset our search range
        searchRange = Range(uncheckedBounds: (lower: line.startIndex, upper: line.endIndex))
    }

    var firstNumberIndex: String.Index = line.endIndex
    var firstKey = ""
    var lastNumberIndex: String.Index = line.startIndex
    var lastKey = ""

    for key in hits.keys {
        var sortedHits = hits[key] ?? []
            sortedHits.sort { index1, index2 in
            return index1 < index2
        }
        hits[key] = sortedHits

        if let first = sortedHits.first, first < firstNumberIndex {
            firstNumberIndex = first
            firstKey = key
        }
        if let last = sortedHits.last, last > lastNumberIndex {
            lastNumberIndex = last
            lastKey = key
        }
    }

    let resultInt = searchTerms[firstKey] ?? 0 //assume no failure to find.
    let resultInt2 = searchTerms[lastKey] ?? resultInt
    print(Int("\(resultInt)\(resultInt2)"))
    return Int("\(resultInt)\(resultInt2)") ?? 0
}
