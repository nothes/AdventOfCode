//
//  day5.swift
//  AOC-2025
//
//  Created by Rachael Worthington on 12/4/25.
//

import Foundation

func day5() {
    let input = readInput(forDay: 5)

    var freshRanges: [(Int, Int)] = []
    var ingredients: [Int] = []
    var pt2Ranges = RangeSet<Int>()

    for line in input.split(separator: "\n") {
        if line.contains("-") {
            // read in fresh ranges
            let spread = line.split(separator: "-")
            freshRanges.append((Int(spread[0])!, Int(spread[1])!))
            pt2Ranges.insert(contentsOf: Int(spread[0])!..<Int(spread[1])! + 1)
        } else {
            ingredients.append(Int(line)!)
        }
    }

//    part1(ingredients: ingredients, freshRanges: freshRanges)
//    part2(freshRanges: freshRanges)
    part2(rangeSet: pt2Ranges)
}

func part1(ingredients: [Int], freshRanges: [(Int, Int)]) {
    var total = 0
    for ingredient in ingredients {
        for range in freshRanges {
            if ingredient >= range.0 && ingredient <= range.1 {
                total += 1
                break
            }
        }
    }
    print("total = \(total)")
}

func part2(rangeSet: RangeSet<Int>) {
    var newSet = RangeSet<Int>()
    let ranges = rangeSet.ranges
    for range in ranges {
        var practicalRange = range
        if newSet.isEmpty {
            newSet.insert(contentsOf: range)
        } else {
            for seenRange in newSet.ranges {
                if seenRange.contains(practicalRange) {
                    // don't care, move on
                    practicalRange = 0..<0
                } else if seenRange.contains(practicalRange.lowerBound) { // we know the lower value is contained within
                    practicalRange = seenRange.upperBound..<practicalRange.upperBound
                } else {
                    assert(!seenRange.contains(practicalRange))
                }
            }
            newSet.insert(contentsOf: practicalRange)
        }
    }
    var total = 0
    for range in newSet.ranges {
        total += range.count
    }
    print(total)
}

// EVERYTHING AFTER THIS DID NOT WORK, FEEL FREE TO JUDGE ME.

func part2(freshRanges: [(Int, Int)]) {
    let moreRanges: [(Int, Int)] = freshRanges.sorted { first, second in
        first.0 < second.0
    }
    let seenRanges: [(Int, Int)] = []

    let result = recursiveTotal(freshRanges: moreRanges, seenRanges: seenRanges)
    print("total = \(result.0)")
}

func recursiveTotal(freshRanges: [(Int, Int)], seenRanges: [(Int, Int)]) -> (Int, [(Int, Int)]) {
    var total = 0
    var seenRanges = seenRanges
    guard let rangeToCount = freshRanges.first else { return (0, []) }

    print("analyzing \(rangeToCount)")
    if seenRanges.isEmpty {
        total = rangeToCount.1 - rangeToCount.0 + 1
        seenRanges.append(rangeToCount)
    } else {
        var practicalRange = rangeToCount
        for seenRange in seenRanges {
            print("practicalRange before: \(practicalRange.0) - \(practicalRange.1)")
            print("seenRange =  \(seenRange.0) - \(seenRange.1)")
            // remove any overlap:
            if practicalRange.0 >= seenRange.0 && practicalRange.1 <= seenRange.1 { // completely within
                assert((seenRange.0...seenRange.1).contains(practicalRange.0))
                assert((seenRange.0...seenRange.1).contains(practicalRange.1))
                print("enclosed")
                practicalRange = (-1,-1)
                break
            } else if practicalRange.0 >= seenRange.0 && practicalRange.0 <= seenRange.1 && practicalRange.1 > seenRange.1 { // overlap hanigng off hte right side
                print("hanging right")
                assert((seenRange.0...seenRange.1).contains(practicalRange.0))
                practicalRange = (seenRange.1 + 1, practicalRange.1)
            }
            else { // doesn't overlap at all, keep em all
                assert(!(seenRange.0...seenRange.1).contains(practicalRange.0))
                assert(!(seenRange.0...seenRange.1).contains(practicalRange.1))
                print("doesn't overlap")
                // no op
            }
            print("practicalRange after: \(practicalRange.0) - \(practicalRange.1)")

            if practicalRange.1 - practicalRange.0 == 0 {
                break
            }
        }
        if practicalRange.1 != -1 && practicalRange.0 != -1 {
            assert(practicalRange.1 >= practicalRange.0)
            seenRanges.append(practicalRange)
            total += practicalRange.1 - practicalRange.0 + 1 // inclusive.
            print("adding items in range \(practicalRange.0) - \(practicalRange.1), adding \(practicalRange.1 - practicalRange.0 + 1)")
        }
    }

    let result = recursiveTotal(freshRanges: Array(freshRanges.dropFirst()), seenRanges: seenRanges)
    total += result.0
    seenRanges.append(contentsOf: result.1)
    print("returning total: \(total)")
    return (total, seenRanges)
}

//344260049617179 - nope
//344260049617199 - nope
//
