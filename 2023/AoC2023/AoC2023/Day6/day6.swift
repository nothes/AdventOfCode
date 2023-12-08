//
//  day6.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/5/23.
//

import Foundation

func day6() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day6/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        //part 1
//        parseRaces(with: text)
//        calculateVariance()

        //part 2
        parseRace(with: text)
        calculateVariance()

    } catch {
        print(error.localizedDescription)
    }
}

struct Race {
    let duration: Int
    let record: Int

    func victoryRange() -> ClosedRange<Int> {
        // holding 0 secs is never going to win, neither is the length of the race.
        var lowest = 1
        var highest = duration - 1

        var result = simulateRace(with: lowest)
        while result <= record {
            lowest = lowest + 1
            result = simulateRace(with: lowest)
        }

        result = simulateRace(with: highest)
        while result <= record {
            highest = highest - 1
            result = simulateRace(with: highest)
        }

        return lowest...highest
    }

    func simulateRace(with buttonDuration: Int) -> Int {
        // each time unit of holding increases speed by 1 time / dist
        guard buttonDuration < duration else { return 0 }
        let travelTime = duration - buttonDuration
        let distance = travelTime * buttonDuration // since we're talking about whole units, duration = speed.

        return distance
    }
}

//Time:      7  15   30
//Distance:  9  40  200

var races: [Race] = []

func parseRaces(with input: String) {
    var times: [Int] = []
    var distances: [Int] = []
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            if line.prefixMatch(of: /Time:/) != nil {
                let timeLine = line.trimmingPrefix(/Time:/)
                times = timeLine.split(separator: /\s+/).map { time in
                    Int(time)!
                }
            } else if line.prefixMatch(of: /Distance:/) != nil {
                let distanceLine = line.trimmingPrefix(/Distance:/)
                distances = distanceLine.split(separator: /\s+/).map { dist in
                    Int(dist)!
                }
            }
        }
    }

    for i in 0..<times.count {
        races.append(Race(duration: times[i], record: distances[i]))
    }
}

func parseRace(with input: String) {
    var times: [Int] = []
    var distances: [Int] = []
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            if line.prefixMatch(of: /Time:/) != nil {
                let timeLine = line.trimmingPrefix(/Time:/)
                let time = timeLine.replacingOccurrences(of: " ", with: "")
                times = [Int(time)!]
            } else if line.prefixMatch(of: /Distance:/) != nil {
                let distanceLine = line.trimmingPrefix(/Distance:/)
                let distance = distanceLine.replacingOccurrences(of: " ", with: "")
                distances = [Int(distance)!]
            }
        }
    }

    for i in 0..<times.count {
        races.append(Race(duration: times[i], record: distances[i]))
    }
}
func calculateVariance() {
    var variance = 1
    for race in races {
        let victories = race.victoryRange()
        variance = variance * victories.distance(from: victories.startIndex, to: victories.endIndex )
    }

    print(variance)
}
