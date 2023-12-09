//
//  day9.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/9/23.
//

import Foundation

func day9() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day9/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parseOASIS(with: text)
        // part 1
        findNextSequences()
        // part 2
        findPreviousSequences()

    } catch {
        print(error.localizedDescription)
    }
}

var sequences: [[Int]] = []

func parseOASIS(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let sequence = line.split(separator: /\s+/).map { str in
                Int(str) ?? 0
            }
            sequences.append(sequence)
        }
    }
}

func findNextSequences() {
    var nextValues: [Int] = []

    for sequence in sequences {
        var sequenceSequences: [[Int]] = [sequence] // first order

        func recursiveDifferenceArray() {
            let lastResult = sequenceSequences.last!
            var nonZero = false
            for item in lastResult {
                if item != 0 {
                    nonZero = true
                }
                if nonZero { break }
            }

            if nonZero == false || lastResult.count < 2 { // can't reduce past 1 value
                return
            }

            var nextResult: [Int] = []
            for i in 0..<lastResult.count - 1 {
                nextResult.append(lastResult[i+1] - lastResult[i])
            }
            sequenceSequences.append(nextResult)
            recursiveDifferenceArray()
        }

        recursiveDifferenceArray()
//        print(sequenceSequences)
        var lastIndex = sequenceSequences.count - 1
        sequenceSequences[lastIndex].append(0)
        lastIndex = lastIndex - 1
        var lastValueToAdd = 0
        while lastIndex >= 0 {
            let valueToAdd = sequenceSequences[lastIndex][sequenceSequences[lastIndex].count - 1]
            sequenceSequences[lastIndex].append(valueToAdd + lastValueToAdd)
            lastValueToAdd = valueToAdd + lastValueToAdd
            lastIndex = lastIndex - 1
        }
        print(sequenceSequences)
        nextValues.append(sequenceSequences[0].last ?? 0)
        var total = 0
        for value in nextValues { total = total + value }
        print("total = \(total)")
    }
}

func findPreviousSequences() {
    var prevValues: [Int] = []

    for sequence in sequences {
        var sequenceSequences: [[Int]] = [sequence] // first order

        func recursiveDifferenceArray() {
            let lastResult = sequenceSequences.last!
            var nonZero = false
            for item in lastResult {
                if item != 0 {
                    nonZero = true
                }
                if nonZero { break }
            }

            if nonZero == false || lastResult.count < 2 { // can't reduce past 1 value
                return
            }

            var nextResult: [Int] = []
            for i in 0..<lastResult.count - 1 {
                nextResult.append(lastResult[i+1] - lastResult[i])
            }
            sequenceSequences.append(nextResult)
            recursiveDifferenceArray()
        }

        recursiveDifferenceArray()
        var lastIndex = sequenceSequences.count - 1
        sequenceSequences[lastIndex].insert(0, at: 0)
        lastIndex = lastIndex - 1
        var lastValueToAdd = 0
        while lastIndex >= 0 {
            let valueToAdd = sequenceSequences[lastIndex][0]
            sequenceSequences[lastIndex].insert(valueToAdd - lastValueToAdd, at: 0)
            lastValueToAdd = valueToAdd - lastValueToAdd
            lastIndex = lastIndex - 1
        }
        print(sequenceSequences)
        prevValues.append(sequenceSequences[0].first ?? 0)
        var total = 0
        for value in prevValues { total = total + value }
        print("total = \(total)")
    }
}
