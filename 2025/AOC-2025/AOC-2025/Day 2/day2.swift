//
//  day2.swift
//  AOC-2025
//
//  Created by Rachael Worthington on 12/1/25.
//

import Foundation

struct Span {
    var start: String
    var end: String
}
func day2()
{
    var input = readInput(forDay: 2)
    if input.last == "\n" {
        input.removeLast()
    }

    let pairs = input.split(separator: ",")

    var ranges: [Span] = []
    for pair in pairs {
        let ids = pair.split(separator: "-")
        ranges.append(Span(start: String(Int(ids[0])!), end: String(Int(ids[1])!)))
    }

//    part1(ranges: ranges)
    part2(ranges: ranges)
}
func part1(ranges: [Span]) {
    var invalidID: Int = 0

    for range in ranges {
        for id in Int(range.start)!...Int(range.end)! {
            let idStr: String = String(id)
            if idStr.count.isMultiple(of: 2) {
                let front = idStr.prefix(idStr.count / 2)
                let back = idStr.suffix(idStr.count / 2)
                if front == back {
                    invalidID += id
                }
            }
        }
    }

    print("total invalid IDs: \(invalidID)")
}

func part2(ranges: [Span]) {
    var invalidID: Int = 0

    for range in ranges {
        for id in Int(range.start)!...Int(range.end)! {
            let idStr: String = String(id)
            if idStr.count == 1 {
                continue
            }
            for length in 1...idStr.count / 2 {
                let divisionInfo = idStr.count.quotientAndRemainder(dividingBy: length)
                if divisionInfo.remainder == 0 { // if it's not a multiple, it can't possibly work.
                    let possibleSubStr = String(idStr.prefix(length))
                    // check if the whole string is that, duplicated.
                    let repeatedStr = String(repeating: possibleSubStr, count: divisionInfo.quotient)
                    if repeatedStr == idStr {
                        print("idstr = \(idStr)") 
                        print("repeatedsubStr: \(repeatedStr)")
                        invalidID += id
                        break
                    }
                }
            }
        }
    }
    print("total 2invalid IDs: \(invalidID)")
}
