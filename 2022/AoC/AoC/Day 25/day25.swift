//
//  day25.swift
//  AoC
//
//  Created by Rachael Worthington on 12/24/22.
//

import Foundation

func day25() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 25/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        convertAndAdd()
    } catch {
        print(error.localizedDescription)
    }
}

var fuelNeeds: [String] = []

fileprivate func parseInput(_ text: String) {
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            fuelNeeds.append(line)
        }
    })
}

func snafuToInt(_ snafuString: String) -> Int {
    // lets parse this string right to left.
    // 1, 5, 25, 125, (*5 each place)
    // digits are 2, 1, 0, -, = (-1, -2)
    var total = 0
    var editableString = String(snafuString)
    var multiplier = 1
    while !editableString.isEmpty {
        let digit = editableString.removeLast()
        switch digit {
        case "2":
            total += 2 * multiplier
        case "1":
            total += multiplier
        case "0":
            print("do a little dance")
        case "-":
            total += -1 * multiplier
        case "=":
            total += -2 * multiplier
        default:
            assertionFailure("what crazy digit bullshit is this?")
        }
        multiplier *= 5
    }

    return total
}

func intToSnafu(_ numb: Int) -> String {
    var num = Int(numb)

    var snafu = ""

    var largestFives = 1
    // figure out your max factor of 5.
    while num / largestFives > 1 {
        largestFives *= 5
    }
    print("largest fives = \(largestFives)")

    var multiplier = largestFives

    while multiplier != 0 {
        // var remainder = num % multiplier

        var digit:Int
        if multiplier != 0 {
            digit = num / multiplier
        } else {
            digit = num
        }
        //    if digit <= 2 {
        snafu.append(String(digit))
        num -= (digit * multiplier)
        multiplier /= 5

    }
    print("final number before snafuizing: \(snafu)")

  //  let validCharString = "210-="
    // ok, now lets start from the 1's digit and move right...
    var index = snafu.index(before: snafu.endIndex)
    var carryValue = 0
    while index >= snafu.startIndex {
        let digit = snafu[index]
        let nextDigit = Int(String(digit))! + carryValue
        carryValue = 0
        if (-2...2).contains(nextDigit) {
            //we're good! move along, sir
            if nextDigit == -1 {
                snafu.remove(at: index)
                snafu.insert("-", at: index)
            } else if nextDigit == -2 {
                snafu.remove(at: index)
                snafu.insert("=", at: index)
            } else {
                snafu.remove(at: index)
                snafu.insert(contentsOf: String(nextDigit), at: index)
            }
        } else {
            // wrap the digit around
            // count the loops?
            carryValue = 1
            var actualValue = nextDigit - 5
            while !(-2...2).contains(actualValue) {
                actualValue -= 5
                carryValue += 1
            }
            var replacementStr: String = ""
            if actualValue == -2 {
                replacementStr = "="
            } else if actualValue == -1 {
                replacementStr = "-"
            } else {
                replacementStr = String(actualValue)
            }
            snafu.remove(at: index)
            assert(replacementStr.count == 1) // we're just dealing w/ digits so this is also a fine check.
            snafu.insert(contentsOf: replacementStr, at: index) // this should be a 1-digit number so this is fine.
        }
        if index == snafu.startIndex {
            break
        }
        index = snafu.index(before: index)
    }

    return snafu
}


func convertAndAdd() {
    var iNumTotal = 0
    for sNum in fuelNeeds {
        iNumTotal += snafuToInt(sNum)
    }
    print("total = \(iNumTotal)")
    let snafu = intToSnafu(iNumTotal)
    print("in snafu: \(snafu)")
}
