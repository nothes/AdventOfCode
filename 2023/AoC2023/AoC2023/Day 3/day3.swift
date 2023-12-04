//
//  day3.swift
//  AoC2023
//
//  Created by Rachael Worthington on 11/30/23.
//

import Foundation

func day3() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day 3/Input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        // do something interesting
        parseSchematicInput(with: text)
        //findPartNumbers()
        findGearRatios()
    } catch {
        print(error.localizedDescription)
    }
}

var schematic: [[String]] = []

func parseSchematicInput(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var schematicLine: [String] = []
            schematicLine.append(".") // pad out our puzzle so we don't have edge-bugs
            for char in line {
                schematicLine.append(String(char)) // lets avoid teh whole char vs string thing by just breaking it up ourselves to start with.
            }
            schematicLine.append(".")// pad out our puzzle so we don't have edge-bugs
            schematic.append(schematicLine)
        }
    }

    // pad out our puzzle so we don't have edge-bugs
    let dotCount = schematic[0].count
    var prefix: [String] = []
    for _ in 0..<dotCount {
        prefix.append(".")
    }
    schematic.append(prefix)
    schematic.insert(prefix, at: 0)
}

func test(for possibleSymbol: String) -> Bool {
    guard let possibleSymbolScalar = Unicode.Scalar(possibleSymbol) else { return false }
    return possibleSymbol != "." && !CharacterSet.decimalDigits.contains(possibleSymbolScalar)
}

func findPartNumbers() {
    var partTotal = 0
    for row in 0..<schematic.count {
        let line = schematic[row]
        var partNumber = ""
        for column in 0...line.count {
            let char = column < line.count ? line[column] : "."
            let scalar = Unicode.Scalar(char)
            let isDecimal = CharacterSet.decimalDigits.contains(scalar!)
            var isPart = false
            if char == "." && partNumber.isEmpty {
                continue // whitespace, more or less
            } else if (char == "." || !isDecimal || column == line.count - 1) && !partNumber.isEmpty { // it could be followed by a symbol
                // done parsing the number, figure out if it's valid.
                // number ends at column-val - 1
                let numEnd = column - 1
                // number starts at column-val - 1 - partNumber.count
                let numStart = numEnd - (partNumber.count - 1)
                //look before
                if numStart > 0 {
                    if test(for: line[numStart - 1]) {
                        isPart = true
                    }
                }
                //look after
                if numEnd < line.count - 1 {
                    if test(for: line[numEnd + 1]) {
                        isPart = true
                    }
                }
                // look diagonal up-left
                if numStart > 0 && row > 0 {
                    if test(for: schematic[row - 1][numStart - 1]) {
                        isPart = true
                    }
                }
                // look above
                if row > 0 {
                    for potentialSymbol in numStart...numEnd {
                        if test(for: schematic[row - 1][potentialSymbol]) {
                            isPart = true
                        }
                    }
                }
                // look diagonal up-right
                if row > 0 && numEnd < line.count - 1 {
                    if test(for: schematic[row - 1][numEnd + 1]) {
                        isPart = true
                    }
                }
                // look diagonal down-left
                if row < schematic.count - 1 && numStart > 0 {
                    if test(for: schematic[row + 1][numStart - 1]) {
                        isPart = true
                    }
                }
                // look below
                if row < schematic.count - 1 {
                    for potentialSymbol in numStart...numEnd {
                        if test(for: schematic[row + 1][potentialSymbol]) {
                            isPart = true
                        }
                    }
                }
                // look diagonal down-right
                if row < schematic.count - 1 && numEnd < line.count - 1 {
                    if test(for: schematic[row + 1][numEnd + 1]) {
                        isPart = true
                    }
                }

                if isPart == true {
                    isPart = false
                    let partInt = Int(partNumber) ?? 0
                    partTotal = partTotal + partInt
                }
                partNumber = ""

            } else if isDecimal {
                partNumber.append(char)
            }

        }
    }
    print(partTotal)
}

// given a coordinate where a digit is, find the entire attached number
func findValueFrom(row rowCoord: Int, column: Int) -> Int {
    let row = schematic[rowCoord]
    var digits = ""
    var numStart = column
    var numEnd = column

    //backwards first
    var scalar = Unicode.Scalar(row[numStart])!
    while CharacterSet.decimalDigits.contains(scalar) {
        numStart = numStart - 1
        scalar = Unicode.Scalar(row[numStart])!
    }
    // that last one wasn't there, step forward one.
    numStart = numStart + 1
    scalar = Unicode.Scalar(row[numStart])!
    numEnd = numStart
    // now forwards, reading it.
    while CharacterSet.decimalDigits.contains(scalar) {
        digits.append(row[numEnd])
        numEnd = numEnd + 1
        scalar = Unicode.Scalar(row[numEnd])!
    }

    return Int(digits) ?? 1
}

func findGearRatios() {
    var gearRatioSum = 0
    var gears: [Int] = []

    for row in 0..<schematic.count {
        let line = schematic[row]
        for column in 0...line.count {
            let char = column < line.count ? line[column] : "."
            if char == "*" {
                // if it's a gear there will be two numbers around it. check all 8 dirs
                // how do you tell if there's just 1 number or 2 across the top or bottom?
                var numCount = 0
                // left
                if let scalar = Unicode.Scalar(line[column - 1]), CharacterSet.decimalDigits.contains(scalar) {
                    numCount = numCount + 1
                    if numCount > 2 {
                        continue // not a gear, too many numbers
                    }
                    gears.append(findValueFrom(row: row, column: column - 1))
                }
                // right
                if let scalar = Unicode.Scalar(line[column + 1]), CharacterSet.decimalDigits.contains(scalar) {
                    numCount = numCount + 1
                    if numCount > 2 {
                        continue // not a gear, too many numbers
                    }
                    gears.append(findValueFrom(row: row, column: column + 1))
                }

                // top
                let rowAbove = schematic[row - 1]
                // there's either one or two numbers here. if there's only one, it could be overlapping any of the 3 positions, but if there are two, they have to be in the upper corners. lets check the center, first, to eliminate the 2-number scenario
                if let scalar = Unicode.Scalar(rowAbove[column]), CharacterSet.decimalDigits.contains(scalar) { // if this is a number, there's only 1.
                    numCount = numCount + 1
                    if numCount > 2 {
                        continue // not a gear, too many numbers
                    }
                    gears.append(findValueFrom(row: row - 1, column: column))
                } else if let scalar = Unicode.Scalar(rowAbove[column - 1]), CharacterSet.decimalDigits.contains(scalar) { // one of possible 2, has to be the end of the number. we already established that the center is not a digit
                    numCount = numCount + 1
                    if numCount > 2 {
                        continue
                    }
                    gears.append(findValueFrom(row: row - 1, column: column - 1))

                    // don't forget to check for a second one
                    if let scalar = Unicode.Scalar(rowAbove[column + 1]), CharacterSet.decimalDigits.contains(scalar) {
                        numCount = numCount + 1
                        if numCount > 2 {
                            continue
                        }
                        gears.append(findValueFrom(row: row - 1, column: column + 1))
                    }
                } else if let scalar = Unicode.Scalar(rowAbove[column + 1]), CharacterSet.decimalDigits.contains(scalar) { // we already checked left of here, this has to be the start of a number, and is the only one in the row.
                    if let scalar = Unicode.Scalar(rowAbove[column + 1]), CharacterSet.decimalDigits.contains(scalar) {
                        numCount = numCount + 1
                        if numCount > 2 {
                            continue
                        }
                        gears.append(findValueFrom(row: row - 1, column: column + 1))
                    }
                }

                // bottom
                let rowBelow = schematic[row + 1]
                // there's either one or two numbers here. if there's only one, it could be overlapping any of the 3 positions, but if there are two, they have to be in the lower corners. lets check the center, first, to eliminate the 2-number scenario
                if let scalar = Unicode.Scalar(rowBelow[column]), CharacterSet.decimalDigits.contains(scalar) { // if this is a number, there's only 1.
                    numCount = numCount + 1
                    if numCount > 2 {
                        continue // not a gear, too many numbers
                    }
                    gears.append(findValueFrom(row: row + 1, column: column))
                } else if let scalar = Unicode.Scalar(rowBelow[column - 1]), CharacterSet.decimalDigits.contains(scalar) { // one of possible 2, has to be the end of the number. we already established that the center is not a digit
                    numCount = numCount + 1
                    if numCount > 2 {
                        continue
                    }
                    gears.append(findValueFrom(row: row + 1, column: column - 1))

                    // don't forget to check for a second one
                    if let scalar = Unicode.Scalar(rowBelow[column + 1]), CharacterSet.decimalDigits.contains(scalar) {
                        numCount = numCount + 1
                        if numCount > 2 {
                            continue
                        }
                        gears.append(findValueFrom(row: row + 1, column: column + 1))
                    }
                } else if let scalar = Unicode.Scalar(rowBelow[column + 1]), CharacterSet.decimalDigits.contains(scalar) { // we already checked left of here, this has to be the start of a number, and is the only one in the row.
                    if let scalar = Unicode.Scalar(rowBelow[column + 1]), CharacterSet.decimalDigits.contains(scalar) {
                        numCount = numCount + 1
                        if numCount > 2 {
                            continue
                        }
                        gears.append(findValueFrom(row: row + 1, column: column + 1))
                    }
                }


                if gears.count == 2 { // we have a gear!
                    print("have a gear at \(row),\(column)")
                    print(gears)
                    let gearRatio = gears[0] * gears[1]
                    gearRatioSum = gearRatioSum + gearRatio
                }
                gears = []
                numCount = 0
            }
        }
    }
    print(gearRatioSum)
}
