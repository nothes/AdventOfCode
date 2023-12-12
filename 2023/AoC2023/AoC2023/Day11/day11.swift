//
//  day11.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/10/23.
//

import Foundation

func day11() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day11/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parseUniverse(with: text)
        // part 1
//        expandSpace()
//        findGalaxies()
//        measureGalaxyDistances()
//        // part 2
        findGalaxies()
        reallyExpandSpace()
        measureGalaxyDistances()

    } catch {
        print(error.localizedDescription)
    }
}

var space: [[Int]] = [] // 0 = space, 1 = galaxy

func parseUniverse(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var row: [Int] = []
            for char in line {
                if char == "#" {
                    row.append(1)
                } else {
                    row.append(0)
                }
            }
            space.append(row)
        }
    }
}

func expandSpace() { // double up empty rows & columns.
    var spaceCopy = space
    space = Array(repeating: [], count: spaceCopy.count)

    // double up columns w/o galaxies
    for column in 0..<spaceCopy[0].count { // for each column
        var hasGalaxy = false
        for row in 0..<spaceCopy.count {
            let value = spaceCopy[row][column]
            if value == 1 {
                hasGalaxy = true
            }
            space[row].append(value)
        }

        if !hasGalaxy { // if there's no galaxy, do it twice!
            for row in 0..<spaceCopy.count {
                space[row].append(0)
            }
        }
        hasGalaxy = false
    }

    spaceCopy = space
    space = []

    // double up rows w/o galaxies
    for i in 0..<spaceCopy.count {
        space.append(spaceCopy[i])
        if spaceCopy[i].contains(1) == false {
            space.append(spaceCopy[i])
        }
    }
}

var galaxies: [(Int, Int)] = []

func findGalaxies() {
    // find all the galaxies.
    for row in 0..<space.count {
        for column in 0..<space[0].count {
            if space[row][column] == 1 {
                galaxies.append((row, column))
            }
        }
    }
}

func reallyExpandSpace() {
    // this operates on the galaxies list, because otherwise, ugh.
    let expansion = 1000000-1
    let spaceRows = space.count
    let spaceColumns = space[0].count

    var emptyRows: [Int] = []
    var emptyColumns: [Int] = []
    
    for row in 0..<spaceRows {
        if space[row].contains(1) == false {
            emptyRows.append(row)
        }
    }

    for column in 0..<spaceColumns { // for each column
        var hasGalaxy = false
        for row in 0..<spaceRows {
            let value = space[row][column]
            if value == 1 {
                hasGalaxy = true
            }
        }

        if !hasGalaxy {
            emptyColumns.append(column)
        }
    }

    // gotta write into a copy, because mutating the original means we can no longer refer to the rows to expand in their original positions.
    var destGalaxies = galaxies
    for row in emptyRows {
        for i in 0..<galaxies.count {
            let galaxy = galaxies[i]
            var destGalaxy = destGalaxies[i]
            if galaxy.0 > row {
                destGalaxy = (destGalaxy.0 + expansion, destGalaxy.1)
            }
            destGalaxies[i] = destGalaxy
        }
    }

    for column in emptyColumns {
        for i in 0..<galaxies.count {
            let galaxy = galaxies[i]
            var destGalaxy = destGalaxies[i]
            if galaxy.1 > column {
                destGalaxy = (destGalaxy.0, destGalaxy.1 + expansion)
            }
            destGalaxies[i] = destGalaxy
        }
    }

    galaxies = destGalaxies

    print("galaxies:\n\(galaxies)")
}

func measureGalaxyDistances() {
    var totalDistance = 0
    var galaxiesToMeasureTo = galaxies
    galaxiesToMeasureTo.removeFirst()
    for galaxy in galaxies {
        for destinationGalaxy in galaxiesToMeasureTo {
            let distance = abs(galaxy.0 - destinationGalaxy.0) + abs(galaxy.1 - destinationGalaxy.1)
            totalDistance = totalDistance + distance
        }
        if !galaxiesToMeasureTo.isEmpty {
            galaxiesToMeasureTo.removeFirst()
        }
    }
    print("total is \(totalDistance)")
}
