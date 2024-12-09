//
//  day8.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/7/24.
//

import Foundation

func day8() {
    let input = readInput(forDay: 8)

    var antennaList: [Antenna] = []
    // parse the map!
    let lines = input.split(separator:"\n")
    var baseMap: [[String]] = []
    var frequencyList: Set<String> = Set()
    for y in 0 ..< lines.count {
        let text = lines[y]
        var row: [String] = []
        var index = text.startIndex
        for x in 0 ..< text.count {
            let char = text[index]
            let location = String(char)
            row.append(location)
            if location != "." {
                frequencyList.insert(location)
                antennaList.append(Antenna(coord:Coord(x: x, y: y) , freq: location))
            }
            index = text.index(after: index)
        }
        baseMap.append(row)
    }

    // these are actually 1 greater, but the duck operator makes that fine.
    let maxY = baseMap.count
    let maxX = baseMap[0].count

    func recursiveCombos(for antennas: [Antenna], partialCombos: [(Antenna, Antenna)]) -> [(Antenna, Antenna)] {
        if antennas.count == 1 {
            return partialCombos
        }
        let firstAnt = antennas.first!
        var combos = partialCombos
        let shorterAntennas = Array(antennas.dropFirst())
        for antenna in shorterAntennas {
            combos.append((firstAnt, antenna))
        }
        return recursiveCombos(for: shorterAntennas, partialCombos: combos)
    }

    var antiNodes: Set<Coord> = Set()
    // for each frequency
    for freq in frequencyList {
        // for each combination of pairs of nodes
        let antennaCombos: [(Antenna, Antenna)] = recursiveCombos(for: antennaList.filter({ ant in
            ant.freq == freq
        }), partialCombos: [])

        // find the anti-nodes.
        for combo in antennaCombos {
            let ant1 = combo.0
            let ant2 = combo.1

            let xDiff = ant1.coord.x - ant2.coord.x
            let yDiff = ant1.coord.y - ant2.coord.y
            var antiNode1 = Coord(x: -1, y: -1)
            var antiNode2 = Coord(x: -1, y: -1)
            if xDiff <= 0 { // first coord is left of 2nd coord (or inline
                antiNode1 = antiNode1.coordWith(xVal: ant1.coord.x + xDiff)
                antiNode2 = antiNode2.coordWith(xVal: ant2.coord.x - xDiff)
            } else {
                antiNode1 = antiNode1.coordWith(xVal: ant1.coord.x + xDiff)
                antiNode2 = antiNode2.coordWith(xVal: ant2.coord.x - xDiff)
            }

            if yDiff <= 0 {
                antiNode1 = antiNode1.coordWith(yVal: ant1.coord.y + yDiff)
                antiNode2 = antiNode2.coordWith(yVal: ant2.coord.y - yDiff)
            } else {
                antiNode1 = antiNode1.coordWith(yVal: ant1.coord.y + yDiff)
                antiNode2 = antiNode2.coordWith(yVal: ant2.coord.y - yDiff)
            }

            if (0 ..< maxX).contains(antiNode1.x) {
                if (0 ..< maxY).contains(antiNode1.y) {
                    antiNodes.insert(antiNode1)
                }
            }
            if (0 ..< maxX).contains(antiNode2.x) {
                if (0 ..< maxY).contains(antiNode2.y) {
                    antiNodes.insert(antiNode2)
                }
            }
        }
    }
    print("antiNode count = \(antiNodes.count)")
    // antinode count (14 for demo data)

    // part 2
    antiNodes = Set(antennaList.map({ ant in
        ant.coord
    }))

    // for each frequency
    for freq in frequencyList {
        // for each combination of pairs of nodes
        let antennaCombos: [(Antenna, Antenna)] = recursiveCombos(for: antennaList.filter({ ant in
            ant.freq == freq
        }), partialCombos: [])

        // find the anti-nodes.
        for combo in antennaCombos {
            let ant1 = combo.0
            let ant2 = combo.1

            let xDiff = ant1.coord.x - ant2.coord.x
            let yDiff = ant1.coord.y - ant2.coord.y

            // find all the nodes before the smaller coord
            var newX = ant1.coord.x + xDiff
            var newY = ant1.coord.y + yDiff
            while (0 ..< maxX).contains(newX) && (0 ..< maxY).contains(newY) {
                antiNodes.insert(Coord(x: newX, y: newY))
                newX = newX + xDiff
                newY = newY + yDiff
            }
            // now all the ones after the larger
            newX = ant2.coord.x - xDiff
            newY = ant2.coord.y - yDiff
            while (0 ..< maxX).contains(newX) && (0 ..< maxY).contains(newY) {
                antiNodes.insert(Coord(x: newX, y: newY))
                newX = newX - xDiff
                newY = newY - yDiff
            }

        }
    }
    print(antiNodes)
    print("expanded antinode count: \(antiNodes.count)")
}

struct Antenna {
    let coord: Coord
    let freq: String
}
//
//XX....X....X
//.X.X....0...
//..X.X0....X.
//..XX...0....
//....X....X..
//.X...XX....X
//...X..X.....
//X....X.X....
//..X.....A...
//....X....A..
//.X........X.
//...X......XX
