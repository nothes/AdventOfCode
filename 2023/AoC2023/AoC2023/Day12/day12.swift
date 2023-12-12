//
//  day12.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/11/23.
//

import Foundation

func day12() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day12/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parseRecords(with: text)
        // part 1
        findSolutionCombos()
        // part 2
    } catch {
        print(error.localizedDescription)
    }
}

var records: [Record] = []

func parseRecords(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let parts = line.split(separator: /\s+/)
            let counts = parts[1].split(separator: ",").map { Int($0)! }
            records.append(Record(diagram: String(parts[0]), counts: counts))
        }
    }
}

enum SpringState: String, CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .broken:
            return "Broken"
        case .operational:
            return "Operational"
        case .unknown:
            return "Unknown"
        }
    }

    case broken = "#"
    case operational = "."
    case unknown = "?"
}

struct StateGroup: CustomDebugStringConvertible {
    let state: SpringState
    let count: Int

    var debugDescription: String {
        return "(\(state), \(count))"
    }
}

struct SpringGroup {
    let broken: Int // must be 1 or more
    let operational: Int // could be 0 in the last one, but otherwise must be 1 or more.
    let unknown: Int // could be 0
}

// THE ALGORITHM: Each spring table can be described as a pair of broken, operational springs, with a possible leading . count. for example "#.#.###" could be 0, [1,1][1,1][3,0], and the first numbers (the brokens) match the number array at the end of the input
// so we know how many sections there have to be. and we can matxh the springs with them.
//
// ????.######..#####. 1,6,5
// ? [1,?][6,?][5,?]

// comparing that with our chart, we can fill in the values, beaxuse we can find the last 2 groups
// ? [1,(at least 1)][6,2][5,1]
// so our only question is "how many places can 1 spring fit in the first 4?" which is 4.

// ?###???????? 3,2,1
// ?[3,?][2,?][1,?]
// so we know from our diagram that
// 1[3,(at least 1)][2,(at least 1)][1,(at least 0)]
// so our question is how to get 2 pairs into the last 7

class Record: CustomDebugStringConvertible {
    var debugDescription: String {
        return "input: \(diagram) \(counts)\nknownInfo: \(initialWorkingSprings) \(springPairCounts)"
    }

    let diagram: String // read in info
    let counts: [Int] // read in info

    // throughout this -1 = unknown
    var initialWorkingSprings = -1 // this could be 0
    var springPairCounts: [(broken: Int, working: Int)] = [] // these count should match the counts array

    init(diagram: String, counts: [Int]) {
        self.diagram = diagram
        self.counts = counts

        for count in counts {
            springPairCounts.append((count, -1))
        }
        generatePartialSolution()
    }

    func generatePartialSolution() {
        // this fills in as many -1's as we can.

        //first of all, can we establish a leading-working-spring count?
        let workingSprings = diagram.prefix { char in
            char == "."
        }
        initialWorkingSprings = workingSprings.count

        var count = 0
        if diagram.last == "." {
            for char in diagram.reversed() {
                if char == "." {
                    count = count + 1
                } else {
                    break
                }
            }
            var newLast = springPairCounts.last!
            if let last = springPairCounts.popLast() {
                newLast = (last.broken, count)
                springPairCounts.append(newLast)
            }
        } else if diagram.last == "#" {
            if let last = springPairCounts.popLast() {
                let newLast = (last.broken, 0)
                springPairCounts.append(newLast)
            }
        }
    }
}

func findSolutionCombos() {
    for record in records {
        print(record)
    }
}
