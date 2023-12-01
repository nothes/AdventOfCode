//: [Previous](@previous)

import Foundation

if let path = Bundle.main.path(forResource: "input", ofType: "txt") {
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
    } catch {
        print(error.localizedDescription)
    }

} else {
    print("where my file?")
}

struct ElfRange {
    var start: Int
    var end: Int

    var rangeLength: Int {
        return end - start + 1
    }
}

var overlapCount = 0

func parseInput(_ text: String) {
    //In how many assignment pairs does one range fully contain the other?
    let elfPairs = text.split(separator: "\n")

    for pair in elfPairs {
        let ranges = pair.split(separator: ",")
        let r1 = ranges[0].split(separator: "-") // string in the form Int-Int
        let r2 = ranges[1].split(separator: "-")

        let range1 = ElfRange(start: Int(r1[0]) ?? 0, end: Int(r1[1]) ?? 0)
        let range2 = ElfRange(start: Int(r2[0]) ?? 0, end: Int(r2[1]) ?? 0)

        // part 1
//        let smallerRange: ElfRange
//        let largerRange: ElfRange
//
//        if (range1.rangeLength < range2.rangeLength) {
//            smallerRange = range1
//            largerRange = range2
//        } else {
//            smallerRange = range2
//            largerRange = range1
//        }
//
//        if largerRange.start <= smallerRange.start && largerRange.end >= smallerRange.end {
//            overlapCount += 1
//        }

        let firstRange: ElfRange
        let secondRange: ElfRange

        if range1.start < range2.start {
            firstRange = range1
            secondRange = range2
        } else {
            firstRange = range2
            secondRange = range1
        }

        print("firstRange: \(firstRange)")
        print("secondRange: \(secondRange)")

        // so they overlap if the second range starts before the first one ends.
        if firstRange.end >= secondRange.start {
            print("overlapped")
            overlapCount += 1
        } else {
            print("no overlap")
        }

    }
    print(overlapCount)
}

//: [Next](@next)
