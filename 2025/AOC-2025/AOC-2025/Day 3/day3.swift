//
//  day3.swift
//  AOC-2025
//
//  Created by Rachael Worthington on 12/2/25.
//

import Foundation

func day3() {

    let batteryArray = readInput(forDay: 3)
    let banks = batteryArray.split(separator: "\n")

//    part1(banks: banks)
    part2(banks: banks)
}

func part1(banks: [String.SubSequence]) {
    var total = 0
    for bank in banks {
        let strBank = String(bank)
        print("current bank: \(strBank)")
        var largestFirstDigit = Int(String(strBank.first!))!
        var largestDigitIndex: String.Index = strBank.startIndex
        var currentDigitIndex = strBank.startIndex
        while currentDigitIndex != strBank.index(before: strBank.endIndex) {
            if largestFirstDigit == 9 {
                break
            }
            let character = String(strBank[currentDigitIndex])
            let digit = Int(character)!
            if digit > largestFirstDigit {
                largestFirstDigit = digit
                largestDigitIndex = currentDigitIndex
            }
            currentDigitIndex = strBank.index(after: currentDigitIndex)
        }

        currentDigitIndex = strBank.index(after: largestDigitIndex)
        var largestLastDigit = Int(String(strBank[currentDigitIndex]))!
//        var largestLastDigitIndex = currentDigitIndex

        while currentDigitIndex < strBank.endIndex {
            if largestLastDigit == 9 {
                break
            }
            let character = String(strBank[currentDigitIndex])
            let digit = Int(character)!
            if digit > largestLastDigit {
                largestLastDigit = digit
//                largestLastDigitIndex = currentDigitIndex
            }
            currentDigitIndex = strBank.index(after: currentDigitIndex)

        }
        print("found \((10*largestFirstDigit + largestLastDigit))")
        total += (10*largestFirstDigit + largestLastDigit)
    }
    print("total = \(total)")
}

func part2(banks: [String.SubSequence]) {
// need exactly 12 digits, so now we're searching inr estricted ranges.
    var total = 0
    var largestDigits: [Int] = Array(repeating: 0, count: 12)
    var associatedIndexes: [String.Index?] = Array(repeating: nil, count: 12)
    for bank in banks {
        let strBank = String(bank)
        print("bank: \(strBank)")
        guard strBank.count > 12 else {
            assert(strBank.count == 12)
            total += Int(strBank)!
            continue
        }
        // to start we search between 0 and 12 before the end (we HAVE to have 12 digits)
        var startIndex = strBank.startIndex
        var endIndex = strBank.index(strBank.endIndex, offsetBy: -12)
        var currentIndex = startIndex
        var largestDigit = Int(String(strBank[startIndex]))!
        var largestIndex: String.Index = startIndex
        for digitIndex in 0..<12 {
            while currentIndex <= endIndex {
                let character = String(strBank[currentIndex])
                let digit = Int(character)!
                print("is \(digit) > \(largestDigit)?")
                if digit > largestDigit {
                    largestDigit = digit
                    largestIndex = currentIndex
                }
                if largestDigit == 9 {
                    break
                }
                currentIndex = strBank.index(after: currentIndex)
            }
            print("settled on \(largestDigit) at index \(largestIndex)")
            // record our results
            largestDigits[digitIndex] = largestDigit
            associatedIndexes[digitIndex] = largestIndex

            if digitIndex < 11 {
                startIndex = strBank.index(after: largestIndex)
                endIndex = strBank.index(after: endIndex)
                currentIndex = startIndex
                largestDigit = Int(String(strBank[startIndex]))!
                largestIndex = startIndex
            }
        }
        print("largestDigits: \(largestDigits)")
        var multiplier = 100000000000
        var subtotal = 0
        for digit in largestDigits {
            subtotal += digit * multiplier
            multiplier /= 10
        }
        total += subtotal
    }
    print("Total: \(total)")
}
