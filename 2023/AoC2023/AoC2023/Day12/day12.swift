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
            var states: [SpringState] = []
            for char in parts[0] {
                states.append(SpringState(rawValue: String(char))!)
            }
            let counts = parts[1].split(separator: ",").map { Int($0)! }
            records.append(Record(diagram: states, counts: counts))
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

struct Record {
    let diagram: [SpringState]
    let counts: [Int]

    func stateGroups() -> [StateGroup] {
        var stateGroups: [StateGroup] = []// type, and number

        var currentGroupType = diagram[0]
        var currentCount = 1

        let diagram = diagram
        for i in 1..<diagram.count {
            let state = diagram[i]
            if state == currentGroupType {
                currentCount = currentCount + 1
            } else {
                stateGroups.append(StateGroup(state: currentGroupType, count: currentCount))
                currentGroupType = state
                currentCount = 1
            }
        }
        stateGroups.append(StateGroup(state: currentGroupType, count: currentCount))

        return stateGroups
    }
}

func findSolutionCombos() {
    for record in records {
      //  let groupsOfBustedSprings = record.counts.count
        let stateGroups = record.stateGroups()
        print("busted counts: \(record.counts)")
        print("current groups: \(stateGroups)")

        // lets see if we can match up the counts with our groups
        var matches: [(StateGroup, Int)] = [] // group and the index of the springCountArray it matches to

        var currentCountIndex = 0
        for state in stateGroups {
            let count = record.counts[currentCountIndex]
            print("\(state) vs \(count) (index: \(currentCountIndex))")
            if state.state == .broken && state.count == count { // these match up. yay!
                matches.append((state, currentCountIndex))
                currentCountIndex = currentCountIndex + 1
            }
        }
        print("these go together, maybe: \(matches)")
    }
}
