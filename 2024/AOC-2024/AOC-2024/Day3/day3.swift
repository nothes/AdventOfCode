//
//  day3.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/2/24.
//

import Foundation
import RegexBuilder

func day3() {
// part 1
    let input = readInput(forDay: 3) // our input is 1 string, no endlines.

    let multRegex = Regex {
        One("mul(")
        Capture {
            OneOrMore {
                .digit
            }
        }
        ","
        Capture {
            OneOrMore {
                .digit
            }
        }
        ")"
    }

    let dontRegex = Regex {
        One("don't()")
    }

    let doRegex = Regex {
        One("do()")
    }

    func lastInputIndex() -> String.Index {
        input.index(before:input.endIndex)
    }
    var multTotal = 0
    let matches = input.matches(of: multRegex)
    for match in matches {
        let value1 = Int(match.output.1)!
        let value2 = Int(match.output.2)!
        multTotal = multTotal + value1 * value2
    }

    print("valid multiplication commands total \(multTotal)")

    // part 2
    var enabled = true
    multTotal = 0


    var disableIndex: String.Index? = input.startIndex
    var enableIndex: String.Index? = input.startIndex

    // we start enabled, so lets look for the first disable.
    if let firstDisableMatch = input.firstMatch(of: dontRegex) {
        disableIndex = firstDisableMatch.startIndex
    }
    // so find any multiply commands in that first substring

    if let disableIndex { // I assume there'll be at least 1 disable/enable cycle in my input, so this should always execute
        let enabledMatches = input[input.startIndex...disableIndex].matches(of: multRegex)
        for match in enabledMatches {
            let value1 = Int(match.output.1)!
            let value2 = Int(match.output.2)!
            multTotal = multTotal + value1 * value2
        }
    }
    //skip to next enable
    if let disableIndex, let firstEnableMatch = input[disableIndex...lastInputIndex()].firstMatch(of: doRegex)
    {
        enableIndex = firstEnableMatch.startIndex
    }

    while let localEnableIndex = enableIndex {
        // find next disable
        if let dontMatch = input[localEnableIndex...lastInputIndex()].firstMatch(of: dontRegex) {
            disableIndex = dontMatch.startIndex
        } else {
            // eat the rest up!
            disableIndex = lastInputIndex()
            enableIndex = nil
        }

        assert(localEnableIndex < disableIndex!)
        // find our next sets of mult cmds.
        let matches = input[localEnableIndex...disableIndex!].matches(of: multRegex)
        for match in matches {
            let value1 = Int(match.output.1)!
            let value2 = Int(match.output.2)!
            multTotal = multTotal + value1 * value2
        }

        //find next enable
        if let _ = enableIndex { // we haven't already zeroed this out
            if let enableMatch = input[disableIndex!...lastInputIndex()].firstMatch(of: doRegex) {
                enableIndex = enableMatch.startIndex
            }
        }
    }


    print("valid do/dont multiplication commands total \(multTotal)")

}

