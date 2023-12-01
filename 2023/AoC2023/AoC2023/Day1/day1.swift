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
        doSomething(with: text)
    } catch {
        print(error.localizedDescription)
    }
}

func doSomething(with input: String) {
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
